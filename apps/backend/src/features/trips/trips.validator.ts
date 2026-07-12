import { z } from "zod";
import { TripStatus, DistanceUnit } from "@prisma/client";

export const getTripsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  status: z.nativeEnum(TripStatus).optional(),
});

export const createTripSchema = z.object({
  tripNumber: z.string().min(1, "Trip number is required").max(100),
  sourceLocationId: z.string().uuid("Invalid source location ID"),
  destinationLocationId: z.string().uuid("Invalid destination location ID"),
  fleetId: z.string().uuid().optional(),
  vehicleId: z.string().uuid("Invalid vehicle ID"),
  driverId: z.string().uuid("Invalid driver ID"),
  scheduledStartAt: z
    .string()
    .datetime()
    .transform((val) => new Date(val)),
  scheduledEndAt: z
    .string()
    .datetime()
    .transform((val) => new Date(val)),
  distance: z.union([z.number(), z.string()]).transform((val) => String(val)),
  distanceUnit: z.nativeEnum(DistanceUnit),
  cargoWeight: z
    .union([z.number(), z.string()])
    .optional()
    .transform((val) => (val !== undefined ? String(val) : undefined)),
  notes: z.string().optional(),
});

export const updateTripStatusSchema = z.object({
  status: z.nativeEnum(TripStatus),
  reason: z.string().optional(),
  notes: z.string().optional(),
});

export type CreateTripInput = z.infer<typeof createTripSchema>;
export type UpdateTripStatusInput = z.infer<typeof updateTripStatusSchema>;
