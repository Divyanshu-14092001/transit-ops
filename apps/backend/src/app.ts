import express, { Request, Response, NextFunction } from "express";
import cors from "cors";
import helmet from "helmet";
import { rateLimit } from "express-rate-limit";
import { HTTP_STATUS } from "@transitops/shared";

const app = express();

// Security Middlewares
app.use(helmet());
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    status: HTTP_STATUS.TOO_MANY_REQUESTS,
    message: "Too many requests from this IP, please try again later.",
  },
});
app.use("/api/", limiter);

// Root Health Check Route
app.get("/health", (_req: Request, res: Response) => {
  res.status(HTTP_STATUS.OK).json({
    status: "success",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// Centralized Error Handling Middleware
app.use(
  (
    err: Error & { status?: number },
    _req: Request,
    res: Response,
    _next: NextFunction,
  ) => {
    const statusCode = err.status || HTTP_STATUS.INTERNAL_SERVER_ERROR;
    const message = err.message || "Internal Server Error";

    // Safe error reporting to avoid leaking stack traces in production
    res.status(statusCode).json({
      status: "error",
      statusCode,
      message:
        process.env.NODE_ENV === "production" &&
        statusCode === HTTP_STATUS.INTERNAL_SERVER_ERROR
          ? "A system error occurred"
          : message,
      ...(process.env.NODE_ENV !== "production" && { stack: err.stack }),
    });
  },
);

export default app;
