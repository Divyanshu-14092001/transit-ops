import { Router } from "express";
import { LocationsController } from "./locations.controller";
import { authenticateToken } from "../../middlewares/auth.middleware";

const router = Router();
const controller = new LocationsController();

router.get("/", authenticateToken as any, controller.getLocations);

export const locationsRouter = router;
