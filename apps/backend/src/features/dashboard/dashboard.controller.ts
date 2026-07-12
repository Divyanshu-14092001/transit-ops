import { Response, NextFunction } from "express";
import { HTTP_STATUS } from "@transitops/shared";
import { AuthenticatedRequest } from "../../middlewares/auth.middleware";
import { DashboardService } from "./dashboard.service";
import { getDashboardQuerySchema } from "./dashboard.validator";

export class DashboardController {
  private dashboardService = new DashboardService();

  getDashboardData = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const query = getDashboardQuerySchema.parse(req.query);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.dashboardService.getDashboardData(
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
}
