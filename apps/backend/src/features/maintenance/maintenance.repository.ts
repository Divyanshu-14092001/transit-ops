import { prisma } from "../../config/prisma";
import { Prisma, MaintenanceStatus, VehicleStatus } from "@prisma/client";

export class MaintenanceRepository {
  async getMaintenanceRecords(
    organizationId: string,
    status?: MaintenanceStatus,
    vehicleId?: string,
  ) {
    const whereClause: Prisma.MaintenanceRecordWhereInput = {
      organizationId,
      deletedAt: null,
    };

    if (status) {
      whereClause.status = status;
    }

    if (vehicleId) {
      whereClause.vehicleId = vehicleId;
    }

    return prisma.maintenanceRecord.findMany({
      where: whereClause,
      include: {
        vehicle: {
          select: {
            id: true,
            vehicleNumber: true,
            registrationNumber: true,
            status: true,
          },
        },
        fleet: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
        createdBy: {
          select: {
            id: true,
            fullName: true,
            email: true,
          },
        },
        updatedBy: {
          select: {
            id: true,
            fullName: true,
            email: true,
          },
        },
      },
      orderBy: {
        createdAt: "desc",
      },
    });
  }

  async createMaintenanceRecord(
    data: Prisma.MaintenanceRecordUncheckedCreateInput,
    userId: string,
  ) {
    return prisma.$transaction(async (tx) => {
      // 1. Create the maintenance record
      const maintenance = await tx.maintenanceRecord.create({
        data,
        include: {
          vehicle: true,
        },
      });

      // 2. Adjust vehicle status and log transitions if status is IN_PROGRESS or COMPLETED
      let targetVehicleStatus: VehicleStatus | null = null;
      let logReason = "";

      if (data.status === MaintenanceStatus.IN_PROGRESS) {
        targetVehicleStatus = VehicleStatus.IN_SHOP;
        logReason = `Vehicle entered maintenance: ${maintenance.maintenanceType}`;
      } else if (data.status === MaintenanceStatus.COMPLETED) {
        targetVehicleStatus = VehicleStatus.AVAILABLE;
        logReason = `Vehicle completed maintenance: ${maintenance.maintenanceType}`;
      }

      if (
        targetVehicleStatus &&
        maintenance.vehicle.status !== targetVehicleStatus
      ) {
        const originalStatus = maintenance.vehicle.status;

        // Update vehicle status
        await tx.vehicle.update({
          where: { id: maintenance.vehicleId },
          data: { status: targetVehicleStatus },
        });

        // Log the status transition
        await tx.vehicleStatusLog.create({
          data: {
            vehicleId: maintenance.vehicleId,
            statusFrom: originalStatus,
            statusTo: targetVehicleStatus,
            reason: logReason,
            updatedById: userId,
          },
        });
      }

      return maintenance;
    });
  }

  async updateMaintenanceRecord(
    id: string,
    organizationId: string,
    data: Prisma.MaintenanceRecordUncheckedUpdateInput,
    userId: string,
  ) {
    return prisma.$transaction(async (tx) => {
      // 1. Find the existing maintenance record
      const existingRecord = await tx.maintenanceRecord.findFirst({
        where: {
          id,
          organizationId,
          deletedAt: null,
        },
        include: {
          vehicle: true,
        },
      });

      if (!existingRecord) {
        throw new Error("Maintenance record not found or access denied");
      }

      // 2. Perform the update
      const updatedMaintenance = await tx.maintenanceRecord.update({
        where: { id },
        data: {
          ...data,
          updatedById: userId,
        },
        include: {
          vehicle: true,
        },
      });

      // 3. Handle vehicle status updates on state transition
      const oldStatus = existingRecord.status;
      const newStatus = updatedMaintenance.status;

      if (oldStatus !== newStatus) {
        let targetVehicleStatus: VehicleStatus | null = null;
        let logReason = "";

        if (newStatus === MaintenanceStatus.IN_PROGRESS) {
          targetVehicleStatus = VehicleStatus.IN_SHOP;
          logReason = `Maintenance started: ${updatedMaintenance.maintenanceType}`;
        } else if (newStatus === MaintenanceStatus.COMPLETED) {
          targetVehicleStatus = VehicleStatus.AVAILABLE;
          logReason = `Maintenance completed: ${updatedMaintenance.maintenanceType}`;
        } else if (
          newStatus === MaintenanceStatus.CANCELLED &&
          existingRecord.vehicle.status === VehicleStatus.IN_SHOP
        ) {
          targetVehicleStatus = VehicleStatus.AVAILABLE;
          logReason = `Maintenance cancelled: ${updatedMaintenance.maintenanceType}`;
        }

        if (
          targetVehicleStatus &&
          existingRecord.vehicle.status !== targetVehicleStatus
        ) {
          const originalVehicleStatus = existingRecord.vehicle.status;

          // Update vehicle status
          await tx.vehicle.update({
            where: { id: existingRecord.vehicleId },
            data: { status: targetVehicleStatus },
          });

          // Log vehicle status transition
          await tx.vehicleStatusLog.create({
            data: {
              vehicleId: existingRecord.vehicleId,
              statusFrom: originalVehicleStatus,
              statusTo: targetVehicleStatus,
              reason: logReason,
              updatedById: userId,
            },
          });
        }
      }

      return updatedMaintenance;
    });
  }
}
