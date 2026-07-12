import { Router } from "express";
import { MaintenanceController } from "./maintenance.controller";
import { authenticateToken } from "../../middlewares/auth.middleware";

const router = Router();
const controller = new MaintenanceController();

// eslint-disable-next-line @typescript-eslint/no-explicit-any
router.get("/", authenticateToken as any, controller.getMaintenanceRecords);
// eslint-disable-next-line @typescript-eslint/no-explicit-any
router.post("/", authenticateToken as any, controller.createMaintenanceRecord);
router.put(
  "/:id",
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  authenticateToken as any,
  controller.updateMaintenanceRecord,
);

export const maintenanceRouter = router;
