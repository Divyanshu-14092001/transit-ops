import { prisma } from "../../config/prisma";
import { Prisma, TripStatus } from "@prisma/client";

export class TripsRepository {
  async getTrips(
    organizationId: string,
    filters: { page: number; limit: number; status?: TripStatus },
  ) {
    const skip = (filters.page - 1) * filters.limit;
    const where: Prisma.TripWhereInput = {
      organizationId,
      deletedAt: null,
      ...(filters.status && { status: filters.status }),
    };

    const [trips, total] = await prisma.$transaction([
      prisma.trip.findMany({
        where,
        skip,
        take: filters.limit,
        include: {
          driver: {
            include: {
              user: {
                select: {
                  fullName: true,
                  email: true,
                  contactNumber: true,
                },
              },
            },
          },
          vehicle: true,
          sourceLocation: true,
          destinationLocation: true,
          statusLogs: {
            include: {
              updatedBy: {
                select: {
                  fullName: true,
                },
              },
            },
            orderBy: {
              createdAt: "asc",
            },
          },
        },
        orderBy: {
          createdAt: "desc",
        },
      }),
      prisma.trip.count({ where }),
    ]);

    return { trips, total };
  }

  async findVehicle(id: string) {
    return prisma.vehicle.findUnique({
      where: { id },
    });
  }

  async findDriver(id: string) {
    return prisma.driver.findUnique({
      where: { id },
    });
  }

  async findTrip(id: string, organizationId: string) {
    return prisma.trip.findFirst({
      where: {
        id,
        organizationId,
        deletedAt: null,
      },
    });
  }

  async createTrip(
    data: Omit<Prisma.TripUncheckedCreateInput, "createdById" | "status">,
    userId: string,
  ) {
    return prisma.$transaction(async (tx) => {
      const trip = await tx.trip.create({
        data: {
          organizationId: data.organizationId,
          tripNumber: data.tripNumber,
          sourceLocationId: data.sourceLocationId,
          destinationLocationId: data.destinationLocationId,
          fleetId: data.fleetId,
          vehicleId: data.vehicleId,
          driverId: data.driverId,
          scheduledStartAt: data.scheduledStartAt,
          scheduledEndAt: data.scheduledEndAt,
          distance: data.distance,
          distanceUnit: data.distanceUnit,
          cargoWeight: data.cargoWeight,
          notes: data.notes,
          status: "DRAFT",
          createdById: userId,
        },
        include: {
          driver: {
            include: {
              user: {
                select: {
                  fullName: true,
                  email: true,
                },
              },
            },
          },
          vehicle: true,
          sourceLocation: true,
          destinationLocation: true,
        },
      });

      await tx.tripStatusLog.create({
        data: {
          tripId: trip.id,
          statusFrom: "DRAFT",
          statusTo: "DRAFT",
          reason: "Initial Trip Creation",
          updatedById: userId,
        },
      });

      return trip;
    });
  }

  async updateTripStatus(
    tripId: string,
    oldStatus: TripStatus,
    newStatus: TripStatus,
    statusData: { reason?: string; notes?: string },
    userId: string,
  ) {
    return prisma.$transaction(async (tx) => {
      const trip = await tx.trip.update({
        where: { id: tripId },
        data: {
          status: newStatus,
          updatedById: userId,
        },
        include: {
          driver: {
            include: {
              user: {
                select: {
                  fullName: true,
                  email: true,
                },
              },
            },
          },
          vehicle: true,
          sourceLocation: true,
          destinationLocation: true,
        },
      });

      // Side effects on Vehicle and Driver Status as per business rules
      if (newStatus === "DISPATCHED") {
        await tx.vehicle.update({
          where: { id: trip.vehicleId },
          data: { status: "ON_TRIP" },
        });
        await tx.vehicleStatusLog.create({
          data: {
            vehicleId: trip.vehicleId,
            statusFrom: "AVAILABLE",
            statusTo: "ON_TRIP",
            reason: "Trip Dispatched",
            updatedById: userId,
          },
        });
        await tx.driver.update({
          where: { id: trip.driverId },
          data: { status: "ON_TRIP" },
        });
      } else if (newStatus === "COMPLETED" || newStatus === "CANCELLED") {
        await tx.vehicle.update({
          where: { id: trip.vehicleId },
          data: { status: "AVAILABLE" },
        });
        await tx.vehicleStatusLog.create({
          data: {
            vehicleId: trip.vehicleId,
            statusFrom: "ON_TRIP",
            statusTo: "AVAILABLE",
            reason:
              newStatus === "COMPLETED" ? "Trip Completed" : "Trip Cancelled",
            updatedById: userId,
          },
        });
        await tx.driver.update({
          where: { id: trip.driverId },
          data: { status: "AVAILABLE" },
        });
      }

      await tx.tripStatusLog.create({
        data: {
          tripId,
          statusFrom: oldStatus,
          statusTo: newStatus,
          reason: statusData.reason || null,
          notes: statusData.notes || null,
          updatedById: userId,
        },
      });

      return trip;
    });
  }
}
