import { Request, Response, NextFunction } from "express";
import { HTTP_STATUS } from "@transitops/shared";
import { AuthService } from "./auth.service";
import { loginSchema } from "./auth.validator";

export class AuthController {
  private authService = new AuthService();

  login = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const input = loginSchema.parse(req.body);
      const result = await this.authService.login(input);

      return res.status(HTTP_STATUS.OK).json({
        status: "success",
        statusCode: HTTP_STATUS.OK,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  };

  logout = async (req: Request, res: Response, next: NextFunction) => {
    try {
      // In stateless JWT auth, logout is primarily a client-side action (clearing the token).
      // We return a success response immediately.
      return res.status(HTTP_STATUS.OK).json({
        status: "success",
        statusCode: HTTP_STATUS.OK,
        message: "Successfully logged out",
      });
    } catch (error) {
      next(error);
    }
  };

  verifyAccessToken = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const authHeader = req.headers["authorization"];
      let token = "";
      if (authHeader) {
        if (authHeader.startsWith("Bearer ")) {
          token = authHeader.substring(7).trim();
        } else {
          token = authHeader.trim();
        }
      }

      // Clean potential enclosing quotes from string payload
      if (token.startsWith('"') && token.endsWith('"')) {
        token = token.slice(1, -1);
      }

      if (!token || token === "undefined" || token === "null") {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          status: "error",
          statusCode: HTTP_STATUS.BAD_REQUEST,
          message: "Authorization token is missing or invalid",
        });
      }

      const userDetails = await this.authService.verifyAccessToken(token);

      return res.status(HTTP_STATUS.OK).json({
        status: "success",
        statusCode: HTTP_STATUS.OK,
        data: {
          user: userDetails,
        },
      });
    } catch (error: any) {
      return res.status(HTTP_STATUS.UNAUTHORIZED).json({
        status: "error",
        statusCode: HTTP_STATUS.UNAUTHORIZED,
        message: error.message || "Invalid or expired access token",
      });
    }
  };
}
