import { prisma } from "../../config/prisma";
import { Prisma, ExpenseStatus, ExpenseType } from "@prisma/client";

export class ExpensesRepository {
  async getExpenses(
    organizationId: string,
    type?: ExpenseType,
    status?: ExpenseStatus,
    vehicleId?: string,
  ) {
    const whereClause: Prisma.ExpenseWhereInput = {
      organizationId,
      deletedAt: null,
    };

    if (type) {
      whereClause.expenseType = type;
    }

    if (status) {
      whereClause.status = status;
    }

    if (vehicleId) {
      whereClause.vehicleId = vehicleId;
    }

    return prisma.expense.findMany({
      where: whereClause,
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
        approvedBy: {
          select: {
            id: true,
            fullName: true,
            email: true,
          },
        },
        fuelLog: true,
      },
      orderBy: {
        expenseDate: "desc",
      },
    });
  }

  async createExpense(data: Prisma.ExpenseUncheckedCreateInput) {
    return prisma.expense.create({
      data,
      include: {
        vehicle: true,
        trip: true,
      },
    });
  }

  async updateExpenseStatus(
    id: string,
    organizationId: string,
    status: ExpenseStatus,
    userId: string,
  ) {
    const updateData: Prisma.ExpenseUncheckedUpdateInput = {
      status,
    };

    if (status === ExpenseStatus.APPROVED) {
      updateData.approvedById = userId;
      updateData.approvedAt = new Date();
    }

    return prisma.expense.update({
      where: {
        id,
        organizationId,
      },
      data: updateData,
      include: {
        vehicle: true,
        trip: true,
        approvedBy: {
          select: {
            id: true,
            fullName: true,
            email: true,
          },
        },
      },
    });
  }
}
