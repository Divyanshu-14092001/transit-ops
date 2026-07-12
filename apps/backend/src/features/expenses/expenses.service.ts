import { prisma } from "../../config/prisma";
import { ExpensesRepository } from "./expenses.repository";
import { CreateExpenseInput } from "./expenses.validator";
import { CustomError } from "../../utils/custom-error";
import { HTTP_STATUS } from "@transitops/shared";
import { ExpenseStatus, ExpenseType, Prisma } from "@prisma/client";

export class ExpensesService {
  private expensesRepository = new ExpensesRepository();

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

  async getExpenses(
    query: {
      expenseType?: ExpenseType;
      status?: ExpenseStatus;
      vehicleId?: string;
    },
    userId: string,
  ) {
    const organizationId = await this.getActiveOrganizationId(userId);
    return this.expensesRepository.getExpenses(
      organizationId,
      query.expenseType,
      query.status,
      query.vehicleId,
    );
  }

  async createExpense(input: CreateExpenseInput, userId: string) {
    const organizationId = await this.getActiveOrganizationId(userId);

    // Resolve vehicle's fleet automatically if vehicleId is provided
    let fleetId = input.fleetId;
    if (input.vehicleId) {
      const vehicle = await prisma.vehicle.findFirst({
        where: {
          id: input.vehicleId,
          organizationId,
          deletedAt: null,
        },
      });

      if (!vehicle) {
        throw new CustomError("Invalid vehicle ID", HTTP_STATUS.BAD_REQUEST);
      }

      if (!fleetId) {
        fleetId = vehicle.fleetId;
      }
    }

    // Resolve trip organization membership
    if (input.tripId) {
      const trip = await prisma.trip.findFirst({
        where: {
          id: input.tripId,
          organizationId,
          deletedAt: null,
        },
      });

      if (!trip) {
        throw new CustomError("Invalid trip ID", HTTP_STATUS.BAD_REQUEST);
      }
    }

    const expenseData: Prisma.ExpenseUncheckedCreateInput = {
      organizationId,
      fleetId,
      vehicleId: input.vehicleId,
      tripId: input.tripId,
      expenseType: input.expenseType,
      amount: new Prisma.Decimal(input.amount),
      currency: "INR",
      expenseDate: input.expenseDate,
      referenceNumber: input.referenceNumber,
      description: input.description,
      receiptUrl: input.receiptUrl,
      status: input.status,
      createdById: userId,
    };

    return this.expensesRepository.createExpense(expenseData);
  }

  async updateExpenseStatus(id: string, status: ExpenseStatus, userId: string) {
    const organizationId = await this.getActiveOrganizationId(userId);

    const expense = await prisma.expense.findFirst({
      where: {
        id,
        organizationId,
        deletedAt: null,
      },
    });

    if (!expense) {
      throw new CustomError("Expense record not found", HTTP_STATUS.NOT_FOUND);
    }

    return this.expensesRepository.updateExpenseStatus(
      id,
      organizationId,
      status,
      userId,
    );
  }
}
