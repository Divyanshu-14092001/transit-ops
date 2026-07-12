import { prisma } from "../../config/prisma";
import { GetDriversQueryInput, CreateDriverInput } from "./drivers.validator";
import bcrypt from "bcrypt";

export class DriversRepository {
  async findDrivers(params: GetDriversQueryInput, organizationId?: string) {
    const { page, limit, userId, status, search, licenseNumber } = params;
    const skip = (page - 1) * limit;

    // If query by licenseNumber, retrieve globally across organizations
    if (licenseNumber) {
      const driver = await prisma.driver.findFirst({
        where: {
          licenseNumber: licenseNumber,
          deletedAt: null,
        },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              contactNumber: true,
              status: true,
              lastLoginAt: true,
              createdAt: true,
            },
          },
          organization: {
            select: {
              id: true,
              name: true,
              code: true,
            },
          },
        },
      });
      return {
        total: driver ? 1 : 0,
        items: driver ? [driver] : [],
        page: 1,
        limit: 1,
        totalPages: driver ? 1 : 0,
      };
    }

    const where: any = {
      deletedAt: null,
    };

    if (organizationId) {
      where.organizationId = organizationId;
    }

    if (userId) {
      where.userId = userId;
    }

    if (status) {
      where.status = status;
    }

    if (search) {
      const cleanSearch = search.trim();
      where.OR = [
        {
          user: {
            fullName: {
              contains: cleanSearch,
              mode: "insensitive",
            },
          },
        },
        {
          employeeCode: {
            contains: cleanSearch,
            mode: "insensitive",
          },
        },
        {
          licenseNumber: {
            contains: cleanSearch,
            mode: "insensitive",
          },
        },
      ];
    }

    const [total, items] = await Promise.all([
      prisma.driver.count({ where }),
      prisma.driver.findMany({
        where,
        skip,
        take: limit,
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              contactNumber: true,
              status: true,
              lastLoginAt: true,
              createdAt: true,
            },
          },
        },
        orderBy: {
          createdAt: "desc",
        },
      }),
    ]);

    return {
      total,
      items,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async createOrUpdateDriver(input: CreateDriverInput, targetOrganizationId: string) {
    return prisma.$transaction(async (tx) => {
      // Find DRIVER role
      const driverRole = await tx.role.findUnique({
        where: { code: "DRIVER" },
      });
      if (!driverRole) {
        throw new Error("System Driver role not found in database.");
      }

      // Check if driver profile already exists by license number
      const existingDriver = await tx.driver.findUnique({
        where: { licenseNumber: input.licenseNumber },
        include: { user: true },
      });

      if (existingDriver) {
        // Update user profile info
        const updatedUser = await tx.user.update({
          where: { id: existingDriver.userId },
          data: {
            fullName: input.fullName,
            contactNumber: input.contactNumber,
          },
        });

        // Check if organization has changed
        if (existingDriver.organizationId !== targetOrganizationId) {
          // Retire old organization membership
          await tx.userOrganization.updateMany({
            where: {
              userId: existingDriver.userId,
              status: "ACTIVE",
            },
            data: {
              status: "INACTIVE",
              leftAt: new Date(),
            },
          });

          // Create new organization membership
          await tx.userOrganization.create({
            data: {
              userId: existingDriver.userId,
              organizationId: targetOrganizationId,
              status: "ACTIVE",
              joinedAt: new Date(),
            },
          });

          // Ensure driver user role exists in the new organization
          const existingUserRole = await tx.userRole.findFirst({
            where: {
              userId: existingDriver.userId,
              roleId: driverRole.id,
              organizationId: targetOrganizationId,
            },
          });

          if (!existingUserRole) {
            await tx.userRole.create({
              data: {
                userId: existingDriver.userId,
                roleId: driverRole.id,
                organizationId: targetOrganizationId,
                isActive: true,
              },
            });
          } else {
            await tx.userRole.updateMany({
              where: {
                userId: existingDriver.userId,
                roleId: driverRole.id,
                organizationId: targetOrganizationId,
              },
              data: { isActive: true },
            });
          }
        }

        // Update driver profile record details and link to the new organization
        const updatedDriver = await tx.driver.update({
          where: { id: existingDriver.id },
          data: {
            organizationId: targetOrganizationId,
            employeeCode: input.employeeCode,
            licenseCategory: input.licenseCategory,
            licenseIssuedAt: input.licenseIssuedAt,
            licenseExpiryDate: input.licenseExpiryDate,
            safetyScore: input.safetyScore,
            status: input.status,
            retiredAt: input.status === "RETIRED" ? new Date() : null,
          },
          include: {
            user: {
              select: {
                id: true,
                fullName: true,
                email: true,
                contactNumber: true,
                status: true,
                lastLoginAt: true,
                createdAt: true,
              },
            },
          },
        });

        return updatedDriver;
      } else {
        // Completely new driver: check if user exists by email
        let user = await tx.user.findUnique({
          where: { email: input.email },
        });

        if (!user) {
          const defaultPasswordHash = await bcrypt.hash("SecurePassword123", 10);
          user = await tx.user.create({
            data: {
              email: input.email,
              fullName: input.fullName,
              contactNumber: input.contactNumber,
              passwordHash: defaultPasswordHash,
              status: "ACTIVE",
            },
          });
        }

        // Create organization membership log
        const existingMembership = await tx.userOrganization.findFirst({
          where: {
            userId: user.id,
            organizationId: targetOrganizationId,
            status: "ACTIVE",
          },
        });

        if (!existingMembership) {
          // Retire any other active organizations first
          await tx.userOrganization.updateMany({
            where: {
              userId: user.id,
              status: "ACTIVE",
            },
            data: {
              status: "INACTIVE",
              leftAt: new Date(),
            },
          });

          await tx.userOrganization.create({
            data: {
              userId: user.id,
              organizationId: targetOrganizationId,
              status: "ACTIVE",
              joinedAt: new Date(),
            },
          });
        }

        // Ensure user role exists
        const existingRole = await tx.userRole.findFirst({
          where: {
            userId: user.id,
            roleId: driverRole.id,
            organizationId: targetOrganizationId,
          },
        });

        if (!existingRole) {
          await tx.userRole.create({
            data: {
              userId: user.id,
              roleId: driverRole.id,
              organizationId: targetOrganizationId,
              isActive: true,
            },
          });
        }

        // Create driver profile record
        const newDriver = await tx.driver.create({
          data: {
            userId: user.id,
            organizationId: targetOrganizationId,
            employeeCode: input.employeeCode,
            licenseNumber: input.licenseNumber,
            licenseCategory: input.licenseCategory,
            licenseIssuedAt: input.licenseIssuedAt,
            licenseExpiryDate: input.licenseExpiryDate,
            safetyScore: input.safetyScore,
            status: input.status,
            retiredAt: input.status === "RETIRED" ? new Date() : null,
          },
          include: {
            user: {
              select: {
                id: true,
                fullName: true,
                email: true,
                contactNumber: true,
                status: true,
                lastLoginAt: true,
                createdAt: true,
              },
            },
          },
        });

        return newDriver;
      }
    });
  }
}
