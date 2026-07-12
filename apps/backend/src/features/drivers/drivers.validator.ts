import { z } from "zod";
import { DriverStatus } from "@prisma/client";

export const getDriversQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  userId: z.string().uuid("Invalid userId UUID format").optional(),
  status: z.nativeEnum(DriverStatus).optional(),
});

export type GetDriversQueryInput = z.infer<typeof getDriversQuerySchema>;
