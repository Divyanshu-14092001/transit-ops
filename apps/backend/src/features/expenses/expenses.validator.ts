import { z } from "zod";
import { ExpenseType, ExpenseStatus } from "@prisma/client";

export const getExpensesQuerySchema = z.object({
  expenseType: z.nativeEnum(ExpenseType).optional(),
  status: z.nativeEnum(ExpenseStatus).optional(),
  vehicleId: z.string().uuid("Invalid vehicle ID format").optional(),
});

export const createExpenseSchema = z.object({
  amount: z.union([z.number(), z.string()]).transform((val) => String(val)),
  expenseType: z.nativeEnum(ExpenseType, {
    errorMap: () => ({ message: "Invalid expense type" }),
  }),
  expenseDate: z
    .string()
    .datetime()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
    .transform((val) => new Date(val)),
  referenceNumber: z.string().max(100).optional().nullable(),
  description: z.string().optional().nullable(),
  receiptUrl: z.string().max(500).optional().nullable(),
  vehicleId: z.string().uuid("Invalid vehicle ID format").optional().nullable(),
  tripId: z.string().uuid("Invalid trip ID format").optional().nullable(),
  fleetId: z.string().uuid("Invalid fleet ID format").optional().nullable(),
  status: z.nativeEnum(ExpenseStatus).optional().default(ExpenseStatus.DRAFT),
});

export const updateExpenseStatusSchema = z.object({
  status: z.nativeEnum(ExpenseStatus),
});

export type CreateExpenseInput = z.infer<typeof createExpenseSchema>;
export type UpdateExpenseStatusInput = z.infer<
  typeof updateExpenseStatusSchema
>;
export type GetExpensesQuery = z.infer<typeof getExpensesQuerySchema>;
