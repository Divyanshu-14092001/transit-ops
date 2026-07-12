import { prisma } from "../../config/prisma";
import { MaintenanceRepository } from "./maintenance.repository";
import {
  CreateMaintenanceInput,
  UpdateMaintenanceInput,
} from "./maintenance.validator";
import { CustomError } from "../../utils/custom-error";
import { HTTP_STATUS } from "@transitops/shared";
import { MaintenanceStatus } from "@prisma/client";

export class MaintenanceService {
  private maintenanceRepository = new MaintenanceRepository();

  private async getActiveOrganizationId(userId: string): Promise<string> {
    const userOrg = await prisma.userOrganization.findFirst({
      where: {
        userId,
        status: "ACTIVE",
      },
    });

    if (!userOrg) {
      throw new CustomError(
        "Unauthorized: User does not belong to any active organization",
        HTTP_STATUS.UNAUTHORIZED,
      );
    }

    return userOrg.organizationId;
  }

  async getMaintenanceRecords(
    query: { status?: MaintenanceStatus; vehicleId?: string },
    userId: string,
  ) {
    const organizationId = await this.getActiveOrganizationId(userId);
    return this.maintenanceRepository.getMaintenanceRecords(
      organizationId,
      query.status,
      query.vehicleId,
    );
  }

  async createMaintenanceRecord(input: CreateMaintenanceInput, userId: string) {
    const organizationId = await this.getActiveOrganizationId(userId);

    // Verify vehicle exists and belongs to the organization
    const vehicle = await prisma.vehicle.findFirst({
      where: {
        id: input.vehicleId,
        organizationId,
        deletedAt: null,
      },
    });

    if (!vehicle) {
      throw new CustomError(
        "The specified vehicle is invalid or does not belong to your organization",
        HTTP_STATUS.BAD_REQUEST,
      );
    }

    // Verify fleet (if provided) exists and belongs to the organization
    if (input.fleetId) {
      const fleet = await prisma.fleet.findFirst({
        where: {
          id: input.fleetId,
          organizationId,
          status: "ACTIVE",
        },
      });

      if (!fleet) {
        throw new CustomError(
          "The specified fleet is invalid or inactive for your organization",
          HTTP_STATUS.BAD_REQUEST,
        );
      }
    }

    // Prepare create input data
    const createData = {
      organizationId,
      fleetId: input.fleetId ?? vehicle.fleetId, // Use specified fleet or fallback to vehicle's default fleet
      vehicleId: input.vehicleId,
      maintenanceType: input.maintenanceType,
      description: input.description,
      status: input.status,
      startedAt: input.startedAt,
      expectedCompletionAt: input.expectedCompletionAt,
      completedAt: input.completedAt,
      odometerReading: input.odometerReading
        ? new Prisma.Decimal(input.odometerReading)
        : null,
      estimatedCost: input.estimatedCost
        ? new Prisma.Decimal(input.estimatedCost)
        : null,
      actualCost: input.actualCost
        ? new Prisma.Decimal(input.actualCost)
        : null,
      serviceProvider: input.serviceProvider,
      invoiceNumber: input.invoiceNumber,
      notes: input.notes,
      createdById: userId,
    };

    return this.maintenanceRepository.createMaintenanceRecord(
      createData,
      userId,
    );
  }

  async updateMaintenanceRecord(
    id: string,
    input: UpdateMaintenanceInput,
    userId: string,
  ) {
    const organizationId = await this.getActiveOrganizationId(userId);

    // Prepare update data payload
    const updateData: Prisma.MaintenanceRecordUncheckedUpdateInput = {};
    if (input.status !== undefined) updateData.status = input.status;
    if (input.startedAt !== undefined) updateData.startedAt = input.startedAt;
    if (input.expectedCompletionAt !== undefined)
      updateData.expectedCompletionAt = input.expectedCompletionAt;
    if (input.completedAt !== undefined)
      updateData.completedAt = input.completedAt;
    if (input.notes !== undefined) updateData.notes = input.notes;
    if (input.invoiceNumber !== undefined)
      updateData.invoiceNumber = input.invoiceNumber;
    if (input.serviceProvider !== undefined)
      updateData.serviceProvider = input.serviceProvider;

    if (input.odometerReading !== undefined) {
      updateData.odometerReading = input.odometerReading
        ? new Prisma.Decimal(input.odometerReading)
        : null;
    }

    if (input.actualCost !== undefined) {
      updateData.actualCost = input.actualCost
        ? new Prisma.Decimal(input.actualCost)
        : null;
    }

    try {
      return await this.maintenanceRepository.updateMaintenanceRecord(
        id,
        organizationId,
        updateData,
        userId,
      );
    } catch (error: unknown) {
      const message =
        error instanceof Error
          ? error.message
          : "Failed to update maintenance record";
      throw new CustomError(message, HTTP_STATUS.NOT_FOUND);
    }
  }
}
import { Prisma } from "@prisma/client";
