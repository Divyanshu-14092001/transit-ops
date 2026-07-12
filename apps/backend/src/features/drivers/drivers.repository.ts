import { prisma } from "../../config/prisma";
import { GetDriversQueryInput } from "./drivers.validator";

export class DriversRepository {
  async findDrivers(params: GetDriversQueryInput) {
    const { page, limit, userId, status } = params;
    const skip = (page - 1) * limit;

    const where: any = {
      deletedAt: null,
    };

    if (userId) {
      where.userId = userId;
    }

    if (status) {
      where.status = status;
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
}
