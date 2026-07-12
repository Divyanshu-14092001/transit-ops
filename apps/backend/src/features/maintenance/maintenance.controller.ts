import { Response, NextFunction } from "express";
import { HTTP_STATUS } from "@transitops/shared";
import { AuthenticatedRequest } from "../../middlewares/auth.middleware";
import { MaintenanceService } from "./maintenance.service";
import {
  getMaintenanceQuerySchema,
  createMaintenanceSchema,
  updateMaintenanceSchema,
} from "./maintenance.validator";

export class MaintenanceController {
  private maintenanceService = new MaintenanceService();

  getMaintenanceRecords = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const query = getMaintenanceQuerySchema.parse(req.query);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.maintenanceService.getMaintenanceRecords(
        query,
        userId,
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

  createMaintenanceRecord = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const input = createMaintenanceSchema.parse(req.body);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.maintenanceService.createMaintenanceRecord(
        input,
        userId,
      );

      return res.status(HTTP_STATUS.CREATED).json({
        status: "success",
        statusCode: HTTP_STATUS.CREATED,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  };

  updateMaintenanceRecord = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const { id } = req.params;
      const input = updateMaintenanceSchema.parse(req.body);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.maintenanceService.updateMaintenanceRecord(
        id,
        input,
        userId,
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
