import { Router } from "express";
import { DriversController } from "./drivers.controller";
import { authenticateToken } from "../../middlewares/auth.middleware";

const router = Router();
const controller = new DriversController();

router.get("/", authenticateToken, controller.getDrivers);

export const driversRouter = router;
