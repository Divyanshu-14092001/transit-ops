import { z } from "zod";
import { DriverStatus, LicenseCategory } from "@prisma/client";

export const getDriversQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  userId: z.string().uuid("Invalid userId UUID format").optional(),
  status: z.nativeEnum(DriverStatus).optional(),
  search: z.string().optional(),
  licenseNumber: z.string().optional(),
});

export type GetDriversQueryInput = z.infer<typeof getDriversQuerySchema>;

export const createDriverSchema = z.object({
  fullName: z.string().min(1, "Full name is required"),
  email: z.string().email("Invalid email address"),
  contactNumber: z.string().optional().nullable(),
  employeeCode: z.string().min(1, "Employee code is required"),
  licenseNumber: z.string().min(1, "License number is required"),
  licenseCategory: z.nativeEnum(LicenseCategory),
  licenseIssuedAt: z.preprocess(
    (val) => (typeof val === "string" ? new Date(val) : val),
    z.date(),
  ),
  licenseExpiryDate: z.preprocess(
    (val) => (typeof val === "string" ? new Date(val) : val),
    z.date(),
  ),
  safetyScore: z.coerce.number().min(0).max(100).default(100),
  status: z.nativeEnum(DriverStatus).default(DriverStatus.AVAILABLE),
});

export type CreateDriverInput = z.infer<typeof createDriverSchema>;
