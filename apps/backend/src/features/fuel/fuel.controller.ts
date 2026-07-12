import { Response, NextFunction } from "express";
import { HTTP_STATUS } from "@transitops/shared";
import { AuthenticatedRequest } from "../../middlewares/auth.middleware";
import { FuelService } from "./fuel.service";
import { createFuelLogSchema } from "./fuel.validator";

export class FuelController {
  private fuelService = new FuelService();

  getFuelLogs = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.fuelService.getFuelLogs(userId);

      return res.status(HTTP_STATUS.OK).json({
        status: "success",
        statusCode: HTTP_STATUS.OK,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  };

  createFuelLog = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const input = createFuelLogSchema.parse(req.body);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.fuelService.createFuelLog(input, userId);

      return res.status(HTTP_STATUS.CREATED).json({
        status: "success",
        statusCode: HTTP_STATUS.CREATED,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  };
}
