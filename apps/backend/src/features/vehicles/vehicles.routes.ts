import { Router } from "express";
import { VehiclesController } from "./vehicles.controller";
import { authenticateToken } from "../../middlewares/auth.middleware";

const router = Router();
const controller = new VehiclesController();

router.get("/", authenticateToken as any, controller.getVehicles);
router.post("/", authenticateToken as any, controller.createVehicle);

export const vehiclesRouter = router;
