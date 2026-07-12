import { z } from "zod";

export const getDashboardQuerySchema = z.object({
  vehicleType: z.string().optional(),
  status: z.string().optional(),
  region: z.string().optional(),
});

export type GetDashboardQuery = z.infer<typeof getDashboardQuerySchema>;
