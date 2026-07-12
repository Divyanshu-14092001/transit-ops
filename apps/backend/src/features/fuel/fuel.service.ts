import { prisma } from "../../config/prisma";
import { FuelRepository } from "./fuel.repository";
import { CreateFuelLogInput } from "./fuel.validator";
import { CustomError } from "../../utils/custom-error";
import { HTTP_STATUS } from "@transitops/shared";
import { Prisma } from "@prisma/client";

export class FuelService {
  private fuelRepository = new FuelRepository();

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

  async getFuelLogs(userId: string) {
    const organizationId = await this.getActiveOrganizationId(userId);
    return this.fuelRepository.getFuelLogs(organizationId);
  }

  async createFuelLog(input: CreateFuelLogInput, userId: string) {
    const organizationId = await this.getActiveOrganizationId(userId);

    // Verify vehicle belongs to organization
    const vehicle = await prisma.vehicle.findFirst({
      where: {
        id: input.vehicleId,
        organizationId,
        deletedAt: null,
      },
    });

    if (!vehicle) {
      throw new CustomError(
        "Invalid vehicle ID or access denied",
        HTTP_STATUS.BAD_REQUEST,
      );
    }

    // Verify trip belongs to organization
    if (input.tripId) {
      const trip = await prisma.trip.findFirst({
        where: {
          id: input.tripId,
          organizationId,
          deletedAt: null,
        },
      });

      if (!trip) {
        throw new CustomError(
          "Invalid trip ID or access denied",
          HTTP_STATUS.BAD_REQUEST,
        );
      }
    }

    const fuelLogData = {
      organizationId,
      fleetId: input.fleetId ?? vehicle.fleetId,
      vehicleId: input.vehicleId,
      tripId: input.tripId,
      fuelType: input.fuelType,
      quantity: new Prisma.Decimal(input.quantity),
      quantityUnit: input.quantityUnit,
      pricePerUnit: new Prisma.Decimal(input.pricePerUnit),
      totalCost: new Prisma.Decimal(input.totalCost),
      fuelledAt: input.fuelledAt,
      odometerReading: new Prisma.Decimal(input.odometerReading),
      fuelStationName: input.fuelStationName,
      receiptNumber: input.receiptNumber,
      notes: input.notes,
      createdById: userId,
    };

    return this.fuelRepository.createFuelLog(fuelLogData, userId);
  }
}
