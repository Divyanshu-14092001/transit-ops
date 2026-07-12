import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { HTTP_STATUS } from "@transitops/shared";

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    email: string;
    permissions: string[];
  };
}

export const authenticateToken = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) => {
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
    return res.status(HTTP_STATUS.UNAUTHORIZED).json({
      status: "error",
      statusCode: HTTP_STATUS.UNAUTHORIZED,
      message: "Access token is missing or invalid",
    });
  }

  try {
    const secret = process.env.JWT_SECRET || "change-this-to-a-secure-random-key";
    const decoded = jwt.verify(token, secret) as {
      id: string;
      email: string;
      permissions: string[];
    };
    
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(HTTP_STATUS.UNAUTHORIZED).json({
      status: "error",
      statusCode: HTTP_STATUS.UNAUTHORIZED,
      message: "Invalid or expired access token",
    });
  }
};
