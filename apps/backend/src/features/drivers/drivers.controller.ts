import { Response, NextFunction } from "express";
import { HTTP_STATUS } from "@transitops/shared";
import { AuthenticatedRequest } from "../../middlewares/auth.middleware";
import { DriversService } from "./drivers.service";
import { getDriversQuerySchema } from "./drivers.validator";

export class DriversController {
  private driversService = new DriversService();

  getDrivers = async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const query = getDriversQuerySchema.parse(req.query);
      const result = await this.driversService.getDrivers(query);

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
