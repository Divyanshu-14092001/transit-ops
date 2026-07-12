import { prisma } from "../../config/prisma";
import { TripsRepository } from "./trips.repository";
import { CreateTripInput, UpdateTripStatusInput } from "./trips.validator";
import { TripStatus, Prisma } from "@prisma/client";

export class TripsService {
  private tripsRepository = new TripsRepository();

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

  async getTrips(
    query: { page: number; limit: number; status?: TripStatus },
    userId: string,
  ) {
    const organizationId = await this.getActiveOrganizationId(userId);
    return this.tripsRepository.getTrips(organizationId, query);
  }

  async createTrip(input: CreateTripInput, userId: string) {
    const organizationId = await this.getActiveOrganizationId(userId);

    // Business Rule: Scheduled timing integrity
    if (input.scheduledEndAt < input.scheduledStartAt) {
      throw new Error(
        "Scheduled end date cannot be earlier than scheduled start date",
      );
    }

    // Business Rule: Vehicle validation (must exist, belong to org, and status must be AVAILABLE)
    const vehicle = await this.tripsRepository.findVehicle(input.vehicleId);
    if (
      !vehicle ||
      vehicle.organizationId !== organizationId ||
      vehicle.deletedAt
    ) {
      throw new Error(
        "Invalid vehicle assignment: vehicle not found or unauthorized",
      );
    }
    if (vehicle.status !== "AVAILABLE") {
      throw new Error(
        `The selected vehicle is currently ${vehicle.status.toLowerCase()} and cannot be assigned to a new trip`,
      );
    }

    // Business Rule: Cargo weight capacity checks
    if (input.cargoWeight) {
      const cargoNum = Number(input.cargoWeight);
      const capacityNum = Number(vehicle.maximumCapacity);
      if (cargoNum > capacityNum) {
        throw new Error(
          `Overload warning: cargo weight (${cargoNum}) exceeds vehicle maximum capacity (${capacityNum})`,
        );
      }
    }

    // Business Rule: Driver validation (must exist, belong to org, and license must not be expired)
    const driver = await this.tripsRepository.findDriver(input.driverId);
    if (
      !driver ||
      driver.organizationId !== organizationId ||
      driver.deletedAt
    ) {
      throw new Error(
        "Invalid driver assignment: driver not found or unauthorized",
      );
    }
    if (driver.licenseExpiryDate < input.scheduledStartAt) {
      throw new Error(
        "Driver assignment rejected: driver license will be expired before the trip starts",
      );
    }
    if (driver.licenseExpiryDate < new Date()) {
      throw new Error("Driver assignment rejected: driver license has expired");
    }

    // Default status in repository transactional creation is 'DRAFT'
    return this.tripsRepository.createTrip(
      {
        organizationId,
        tripNumber: input.tripNumber,
        sourceLocationId: input.sourceLocationId,
        destinationLocationId: input.destinationLocationId,
        fleetId: input.fleetId || vehicle.fleetId || undefined,
        vehicleId: input.vehicleId,
        driverId: input.driverId,
        scheduledStartAt: input.scheduledStartAt,
        scheduledEndAt: input.scheduledEndAt,
        distance: input.distance,
        distanceUnit: input.distanceUnit,
        cargoWeight: input.cargoWeight
          ? new Prisma.Decimal(input.cargoWeight)
          : null,
        notes: input.notes || null,
      },
      userId,
    );
  }

  async updateTripStatus(
    tripId: string,
    statusInput: UpdateTripStatusInput,
    userId: string,
  ) {
    const organizationId = await this.getActiveOrganizationId(userId);

    const trip = await this.tripsRepository.findTrip(tripId, organizationId);
    if (!trip) {
      throw new Error("Trip not found or unauthorized access");
    }

    return this.tripsRepository.updateTripStatus(
      tripId,
      trip.status,
      statusInput.status,
      statusInput,
      userId,
    );
  }
}
