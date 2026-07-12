import { z } from "zod";
import { MaintenanceType, MaintenanceStatus } from "@prisma/client";

export const getMaintenanceQuerySchema = z.object({
  status: z.nativeEnum(MaintenanceStatus).optional(),
  vehicleId: z.string().uuid("Invalid vehicle ID format").optional(),
});

export const createMaintenanceSchema = z.object({
  vehicleId: z.string().uuid("Invalid vehicle ID format"),
  fleetId: z.string().uuid("Invalid fleet ID format").optional().nullable(),
  maintenanceType: z.nativeEnum(MaintenanceType, {
    errorMap: () => ({ message: "Invalid maintenance type" }),
  }),
  description: z.string().optional().nullable(),
  status: z
    .nativeEnum(MaintenanceStatus)
    .optional()
    .default(MaintenanceStatus.SCHEDULED),
  startedAt: z
    .string()
    .datetime()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
    .transform((val) => new Date(val)),
  expectedCompletionAt: z
    .string()
    .datetime()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
    .optional()
    .nullable()
    .transform((val) => (val ? new Date(val) : null)),
  completedAt: z
    .string()
    .datetime()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
    .optional()
    .nullable()
    .transform((val) => (val ? new Date(val) : null)),
  odometerReading: z
    .union([z.number(), z.string()])
    .optional()
    .nullable()
    .transform((val) =>
      val !== undefined && val !== null ? String(val) : null,
    ),
  estimatedCost: z
    .union([z.number(), z.string()])
    .optional()
    .nullable()
    .transform((val) =>
      val !== undefined && val !== null ? String(val) : null,
    ),
  actualCost: z
    .union([z.number(), z.string()])
    .optional()
    .nullable()
    .transform((val) =>
      val !== undefined && val !== null ? String(val) : null,
    ),
  serviceProvider: z.string().max(255).optional().nullable(),
  invoiceNumber: z.string().max(100).optional().nullable(),
  notes: z.string().optional().nullable(),
});

export const updateMaintenanceSchema = z.object({
  status: z.nativeEnum(MaintenanceStatus).optional(),
  startedAt: z
    .string()
    .datetime()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
    .optional()
    .transform((val) => (val ? new Date(val) : undefined)),
  expectedCompletionAt: z
    .string()
    .datetime()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
    .optional()
    .nullable()
    .transform((val) => (val ? new Date(val) : null)),
  completedAt: z
    .string()
    .datetime()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
    .optional()
    .nullable()
    .transform((val) => (val ? new Date(val) : null)),
  odometerReading: z
    .union([z.number(), z.string()])
    .optional()
    .nullable()
    .transform((val) =>
      val !== undefined && val !== null ? String(val) : null,
    ),
  actualCost: z
    .union([z.number(), z.string()])
    .optional()
    .nullable()
    .transform((val) =>
      val !== undefined && val !== null ? String(val) : null,
    ),
  notes: z.string().optional().nullable(),
  invoiceNumber: z.string().max(100).optional().nullable(),
  serviceProvider: z.string().max(255).optional().nullable(),
});

export type CreateMaintenanceInput = z.infer<typeof createMaintenanceSchema>;
export type UpdateMaintenanceInput = z.infer<typeof updateMaintenanceSchema>;
export type GetMaintenanceQuery = z.infer<typeof getMaintenanceQuerySchema>;
