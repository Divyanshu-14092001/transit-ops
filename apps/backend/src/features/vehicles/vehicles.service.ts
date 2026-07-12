import { prisma } from "../../config/prisma";
import { VehiclesRepository } from "./vehicles.repository";
import { CreateVehicleInput } from "./vehicles.validator";
import { CustomError } from "../../utils/custom-error";
import { HTTP_STATUS } from "@transitops/shared";
import { VehicleStatus } from "@prisma/client";

export class VehiclesService {
  private vehiclesRepository = new VehiclesRepository();

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

  async getVehicles(
    query: { registrationNumber?: string; status?: VehicleStatus },
    userId: string,
  ) {
    const organizationId = await this.getActiveOrganizationId(userId);
    return this.vehiclesRepository.getVehicles(
      organizationId,
      query.registrationNumber,
      query.status,
    );
  }

  async createVehicle(input: CreateVehicleInput, userId: string) {
    const organizationId = await this.getActiveOrganizationId(userId);

    // Resolve or create an active fleet for assignment
    let fleet = await this.vehiclesRepository.findActiveFleet(
      organizationId,
      input.fleetId,
    );
    if (!fleet) {
      if (input.fleetId) {
        throw new CustomError(
          "The specified fleet is invalid or inactive for your organization",
          HTTP_STATUS.BAD_REQUEST,
        );
      }
      // Create a default fleet if no fleet exists at all
      fleet = await this.vehiclesRepository.createDefaultFleet(organizationId);
    }

    return this.vehiclesRepository.createVehicle(
      {
        organizationId,
        fleetId: fleet.id,
        vehicleNumber: input.vehicleNumber,
        registrationNumber: input.registrationNumber,
        chassisNumber: input.chassisNumber,
        vehicleType: input.vehicleType,
        acquisitionCost: input.acquisitionCost,
        acquisitionDate: input.acquisitionDate,
        manufacturingYear: input.manufacturingYear,
        capacityType: input.capacityType,
        maximumCapacity: input.maximumCapacity,
        capacityUnit: input.capacityUnit,
        odometerReading: input.odometerReading,
        status: input.status,
      },
      userId,
    );
  }
}
