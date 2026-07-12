import { Router } from "express";
import { TripsController } from "./trips.controller";
import { authenticateToken } from "../../middlewares/auth.middleware";

const router = Router();
const controller = new TripsController();

router.get("/", authenticateToken as any, controller.getTrips);
router.post("/", authenticateToken as any, controller.createTrip);
router.patch(
  "/:id/status",
  authenticateToken as any,
  controller.updateTripStatus,
);

export const tripsRouter = router;
