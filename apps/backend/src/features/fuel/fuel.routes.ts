import { Router } from "express";
import { FuelController } from "./fuel.controller";
import { authenticateToken } from "../../middlewares/auth.middleware";

const router = Router();
const controller = new FuelController();

// eslint-disable-next-line @typescript-eslint/no-explicit-any
router.get("/", authenticateToken as any, controller.getFuelLogs);
// eslint-disable-next-line @typescript-eslint/no-explicit-any
router.post("/", authenticateToken as any, controller.createFuelLog);

export const fuelRouter = router;
