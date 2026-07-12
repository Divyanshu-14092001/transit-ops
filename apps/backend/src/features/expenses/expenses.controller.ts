import { Response, NextFunction } from "express";
import { HTTP_STATUS } from "@transitops/shared";
import { AuthenticatedRequest } from "../../middlewares/auth.middleware";
import { ExpensesService } from "./expenses.service";
import {
  getExpensesQuerySchema,
  createExpenseSchema,
  updateExpenseStatusSchema,
} from "./expenses.validator";

export class ExpensesController {
  private expensesService = new ExpensesService();

  getExpenses = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const query = getExpensesQuerySchema.parse(req.query);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.expensesService.getExpenses(query, userId);

      return res.status(HTTP_STATUS.OK).json({
        status: "success",
        statusCode: HTTP_STATUS.OK,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  };

  createExpense = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const input = createExpenseSchema.parse(req.body);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.expensesService.createExpense(input, userId);

      return res.status(HTTP_STATUS.CREATED).json({
        status: "success",
        statusCode: HTTP_STATUS.CREATED,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  };

  updateExpenseStatus = async (
    req: AuthenticatedRequest,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const { id } = req.params;
      const input = updateExpenseStatusSchema.parse(req.body);
      const userId = req.user?.id;

      if (!userId) {
        return res.status(HTTP_STATUS.UNAUTHORIZED).json({
          status: "error",
          statusCode: HTTP_STATUS.UNAUTHORIZED,
          message: "Unauthorized access",
        });
      }

      const result = await this.expensesService.updateExpenseStatus(
        id,
        input.status,
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
