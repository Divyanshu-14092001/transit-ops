import { Response, NextFunction } from "express";
import { HTTP_STATUS } from "@transitops/shared";
import { AuthenticatedRequest } from "../../middlewares/auth.middleware";
import { TripsService } from "./trips.service";
import {
  getTripsQuerySchema,
  createTripSchema,
  updateTripStatusSchema,
} from "./trips.validator";
import { z } from "zod";

export class TripsController {
  private tripsService = new TripsService();

  getTrips = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const query = getTripsQuerySchema.parse(req.query);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const { trips, total } = await this.tripsService.getTrips(query, userId);

      return res.status(HTTP_STATUS.OK).json({
        status: "success",
        statusCode: HTTP_STATUS.OK,
        data: {
          trips,
          pagination: {
            total,
            page: query.page,
            limit: query.limit,
            totalPages: Math.ceil(total / query.limit),
          },
        },
      });
    } catch (error) {
      next(error);
    }
  };

  createTrip = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const input = createTripSchema.parse(req.body);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.tripsService.createTrip(input, userId);

      return res.status(HTTP_STATUS.CREATED).json({
        status: "success",
        statusCode: HTTP_STATUS.CREATED,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  };

  updateTripStatus = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const tripId = z.string().uuid("Invalid trip ID").parse(req.params.id);
      const input = updateTripStatusSchema.parse(req.body);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.tripsService.updateTripStatus(
        tripId,
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
