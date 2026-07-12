import { z } from "zod";
import {
  VehicleType,
  VehicleCapacityType,
  CapacityUnit,
  VehicleStatus,
} from "@prisma/client";

export const getVehiclesQuerySchema = z.object({
  registrationNumber: z.string().optional(),
});

export const createVehicleSchema = z.object({
  vehicleNumber: z.string().min(1, "Vehicle number is required").max(50),
  registrationNumber: z
    .string()
    .min(1, "Registration number is required")
    .max(50),
  chassisNumber: z.string().min(1, "Chassis number is required").max(100),
  vehicleType: z.nativeEnum(VehicleType),
  acquisitionCost: z
    .union([z.number(), z.string()])
    .transform((val) => String(val)),
  acquisitionDate: z
    .string()
    .datetime()
    .or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/))
    .transform((val) => new Date(val)),
  manufacturingYear: z
    .number()
    .int()
    .min(1900)
    .max(new Date().getFullYear() + 1),
  capacityType: z.nativeEnum(VehicleCapacityType),
  maximumCapacity: z
    .union([z.number(), z.string()])
    .transform((val) => String(val)),
  capacityUnit: z.nativeEnum(CapacityUnit),
  odometerReading: z
    .union([z.number(), z.string()])
    .transform((val) => String(val)),
  status: z
    .nativeEnum(VehicleStatus)
    .optional()
    .default(VehicleStatus.AVAILABLE),
  fleetId: z.string().uuid().optional(),
});

export type CreateVehicleInput = z.infer<typeof createVehicleSchema>;
