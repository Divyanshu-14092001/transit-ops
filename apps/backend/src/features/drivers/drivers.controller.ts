import { Response, NextFunction } from "express";
import { HTTP_STATUS } from "@transitops/shared";
import { AuthenticatedRequest } from "../../middlewares/auth.middleware";
import { DriversService } from "./drivers.service";
import { getDriversQuerySchema, createDriverSchema } from "./drivers.validator";
import { prisma } from "../../config/prisma";

export class DriversController {
  private driversService = new DriversService();

  private async getActiveOrganization(userId: string): Promise<string> {
    const userOrg = await prisma.userOrganization.findFirst({
      where: {
        userId,
        status: "ACTIVE",
      },
    });

    if (!userOrg) {
      throw new Error(
        "Unauthorized: User does not belong to any active organization",
      );
    }

    return userOrg.organizationId;
  }

  getDrivers = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const query = getDriversQuerySchema.parse(req.query);

      // If querying globally by licenseNumber, we don't scope by organization
      let organizationId: string | undefined;
      if (!query.licenseNumber && req.user) {
        organizationId = await this.getActiveOrganization(req.user.id);
      }

      const result = await this.driversService.getDrivers(
        query,
        organizationId,
      );

      return res.status(HTTP_STATUS.OK).json({
        status: "success",
        statusCode: HTTP_STATUS.OK,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  };

  createOrUpdateDriver = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      if (!req.user) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Authentication required",
        });
      }

      const input = createDriverSchema.parse(req.body);
      const organizationId = await this.getActiveOrganization(req.user.id);
      const result = await this.driversService.createOrUpdateDriver(
        input,
        organizationId,
      );

      return res.status(HTTP_STATUS.OK).json({
        status: "success",
        statusCode: HTTP_STATUS.OK,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  };
}
