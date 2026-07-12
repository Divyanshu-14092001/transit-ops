import { Request, Response, NextFunction } from "express";
import { HTTP_STATUS } from "@transitops/shared";
import { LocationsService } from "./locations.service";

export class LocationsController {
  private locationsService = new LocationsService();

  getLocations = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const locations = await this.locationsService.getLocations();
      return res.status(HTTP_STATUS.OK).json({
        status: "success",
        statusCode: HTTP_STATUS.OK,
        data: locations,
      });
    } catch (error) {
      next(error);
    }
  };
}
