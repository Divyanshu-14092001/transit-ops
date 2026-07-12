import { z } from "zod";
import { FuelType, FuelQuantityUnit } from "@prisma/client";

export const createFuelLogSchema = z.object({
  vehicleId: z.string().uuid("Invalid vehicle ID format"),
  tripId: z.string().uuid("Invalid trip ID format").optional().nullable(),
  fleetId: z.string().uuid("Invalid fleet ID format").optional().nullable(),
  fuelType: z.nativeEnum(FuelType, {
    errorMap: () => ({ message: "Invalid fuel type" }),
  }),
  quantity: z.union([z.number(), z.string()]).transform((val) => String(val)),
  quantityUnit: z.nativeEnum(FuelQuantityUnit, {
    errorMap: () => ({ message: "Invalid quantity unit" }),
  }),
  pricePerUnit: z
    .union([z.number(), z.string()])
    .transform((val) => String(val)),
  totalCost: z.union([z.number(), z.string()]).transform((val) => String(val)),
  fuelledAt: z
    .string()
    .datetime()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
    .transform((val) => new Date(val)),
  odometerReading: z
    .union([z.number(), z.string()])
    .transform((val) => String(val)),
  fuelStationName: z.string().max(255).optional().nullable(),
  receiptNumber: z.string().max(100).optional().nullable(),
  notes: z.string().optional().nullable(),
});

export type CreateFuelLogInput = z.infer<typeof createFuelLogSchema>;
