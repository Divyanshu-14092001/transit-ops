import { prisma } from "../../config/prisma";
import { Prisma } from "@prisma/client";

export class FuelRepository {
  async getFuelLogs(organizationId: string) {
    return prisma.fuelLog.findMany({
      where: {
        organizationId,
      },
      include: {
        vehicle: {
          select: {
            id: true,
            vehicleNumber: true,
            registrationNumber: true,
          },
        },
        trip: {
          select: {
            id: true,
            tripNumber: true,
          },
        },
        createdBy: {
          select: {
            id: true,
            fullName: true,
            email: true,
          },
        },
        expense: true,
      },
      orderBy: {
        fuelledAt: "desc",
      },
    });
  }

  async createFuelLog(
    data: Omit<Prisma.FuelLogUncheckedCreateInput, "expenseId">,
    userId: string,
  ) {
    return prisma.$transaction(async (tx) => {
      // 1. Create the associated Expense first
      const expense = await tx.expense.create({
        data: {
          organizationId: data.organizationId,
          fleetId: data.fleetId,
          vehicleId: data.vehicleId,
          tripId: data.tripId,
          expenseType: "FUEL",
          amount: data.totalCost,
          currency: "INR",
          expenseDate: data.fuelledAt,
          description: `Fuel log entry: ${data.quantity} units of ${data.fuelType} filled at ${data.fuelStationName || "Station"}.`,
          status: "APPROVED", // Fuel logs are pre-approved since they are logged direct operations
          createdById: userId,
        },
      });

      // 2. Create the FuelLog pointing to the Expense
      const fuelLog = await tx.fuelLog.create({
        data: {
          organizationId: data.organizationId,
          expenseId: expense.id,
          fleetId: data.fleetId,
          vehicleId: data.vehicleId,
          tripId: data.tripId,
          fuelType: data.fuelType,
          quantity: data.quantity,
          quantityUnit: data.quantityUnit,
          pricePerUnit: data.pricePerUnit,
          totalCost: data.totalCost,
          fuelledAt: data.fuelledAt,
          odometerReading: data.odometerReading,
          fuelStationName: data.fuelStationName,
          receiptNumber: data.receiptNumber,
          notes: data.notes,
          createdById: userId,
        },
        include: {
          expense: true,
          vehicle: true,
          trip: true,
        },
      });

      return fuelLog;
    });
  }
}
