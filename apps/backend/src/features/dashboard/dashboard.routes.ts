import { Router } from "express";
import { DashboardController } from "./dashboard.controller";
import { authenticateToken } from "../../middlewares/auth.middleware";

const router = Router();
const controller = new DashboardController();

// eslint-disable-next-line @typescript-eslint/no-explicit-any
router.get("/", authenticateToken as any, controller.getDashboardData);

export const dashboardRouter = router;
