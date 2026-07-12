import { Router } from "express";
import { ExpensesController } from "./expenses.controller";
import { authenticateToken } from "../../middlewares/auth.middleware";

const router = Router();
const controller = new ExpensesController();

// eslint-disable-next-line @typescript-eslint/no-explicit-any
router.get("/", authenticateToken as any, controller.getExpenses);
// eslint-disable-next-line @typescript-eslint/no-explicit-any
router.post("/", authenticateToken as any, controller.createExpense);
router.put(
  "/:id/status",
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  authenticateToken as any,
  controller.updateExpenseStatus,
);

export const expensesRouter = router;
