import { prisma } from "../../config/prisma";
import { VehiclesRepository } from "./vehicles.repository";
import { CreateVehicleInput } from "./vehicles.validator";

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
      throw new Error(
        "Unauthorized: User does not belong to any active organization",
      );
    }

    return userOrg.organizationId;
  }

  async getVehicles(query: { registrationNumber?: string }, userId: string) {
    const organizationId = await this.getActiveOrganizationId(userId);
    return this.vehiclesRepository.getVehicles(
      organizationId,
      query.registrationNumber,
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
        throw new Error(
          "The specified fleet is invalid or inactive for your organization",
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
