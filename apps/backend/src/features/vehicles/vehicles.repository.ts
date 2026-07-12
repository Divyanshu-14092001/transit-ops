import { prisma } from "../../config/prisma";
import { Prisma } from "@prisma/client";

export class VehiclesRepository {
  async getVehicles(organizationId: string, registrationNumber?: string) {
    if (registrationNumber) {
      return prisma.vehicle.findFirst({
        where: {
          organizationId,
          registrationNumber,
          deletedAt: null,
        },
        include: {
          fleet: true,
        },
      });
    }

    return prisma.vehicle.findMany({
      where: {
        organizationId,
        deletedAt: null,
      },
      include: {
        fleet: true,
      },
      orderBy: {
        createdAt: "desc",
      },
    });
  }

  async findActiveFleet(organizationId: string, fleetId?: string) {
    if (fleetId) {
      return prisma.fleet.findFirst({
        where: {
          id: fleetId,
          organizationId,
          status: "ACTIVE",
        },
      });
    }

    return prisma.fleet.findFirst({
      where: {
        organizationId,
        status: "ACTIVE",
      },
    });
  }

  async createDefaultFleet(organizationId: string) {
    return prisma.fleet.create({
      data: {
        organizationId,
        name: "Default Fleet",
        code: `DFT_FLEET_${Date.now().toString().slice(-4)}`,
        status: "ACTIVE",
      },
    });
  }

  async createVehicle(
    data: Omit<Prisma.VehicleUncheckedCreateInput, "fleetId"> & { fleetId: string },
    userId: string
  ) {
    return prisma.$transaction(async (tx) => {
      // 1. Create vehicle record
      const vehicle = await tx.vehicle.create({
        data: {
          organizationId: data.organizationId,
          fleetId: data.fleetId,
          vehicleNumber: data.vehicleNumber,
          registrationNumber: data.registrationNumber,
          chassisNumber: data.chassisNumber,
          vehicleType: data.vehicleType,
          acquisitionCost: data.acquisitionCost,
          acquisitionDate: data.acquisitionDate,
          manufacturingYear: data.manufacturingYear,
          capacityType: data.capacityType,
          maximumCapacity: data.maximumCapacity,
          capacityUnit: data.capacityUnit,
          odometerReading: data.odometerReading,
          status: data.status,
        },
        include: {
          fleet: true,
        },
      });

      // 2. Log initial vehicle status in status logs
      await tx.vehicleStatusLog.create({
        data: {
          vehicleId: vehicle.id,
          statusFrom: "AVAILABLE",
          statusTo: vehicle.status,
          reason: "Initial Registration",
          updatedById: userId,
        },
      });

      // 3. Create active assignment mapping
      await tx.vehicleFleetAssignment.create({
        data: {
          vehicleId: vehicle.id,
          fleetId: data.fleetId,
          assignedById: userId,
        },
      });

      return vehicle;
    });
  }
}
