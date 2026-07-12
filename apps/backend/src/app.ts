import express, { Request, Response, NextFunction } from "express";
import cors from "cors";
import helmet from "helmet";
import { rateLimit } from "express-rate-limit";
import { HTTP_STATUS } from "@transitops/shared";
import { authRouter } from "./features/auth/auth.routes";
import { driversRouter } from "./features/drivers/drivers.routes";
import { vehiclesRouter } from "./features/vehicles/vehicles.routes";
import { tripsRouter } from "./features/trips/trips.routes";
import { locationsRouter } from "./features/locations/locations.routes";
import { maintenanceRouter } from "./features/maintenance/maintenance.routes";
import { dashboardRouter } from "./features/dashboard/dashboard.routes";

const app = express();


// Security Middlewares
app.use(helmet());
const allowedOrigins = [
  process.env.FRONTEND_URL,
  process.env.CORS_ORIGIN,
  "http://localhost:3000",
  "http://localhost:5000",
  "http://localhost:8080",
  "http://localhost:5500",
  "http://127.0.0.1:3000",
  "http://127.0.0.1:5000",
  "http://127.0.0.1:8080",
].filter(Boolean) as string[];

const cleanAllowedOrigins = allowedOrigins.map((origin) =>
  origin.replace(/\/$/, ""),
);

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin) {
        return callback(null, true);
      }
      const cleanOrigin = origin.replace(/\/$/, "");
      if (
        cleanAllowedOrigins.includes(cleanOrigin) ||
        cleanAllowedOrigins.includes("*")
      ) {
        callback(null, true);
      } else {
        callback(new Error("Not allowed by CORS"));
      }
    },
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
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

// API Routes
app.use("/api/auth", authRouter);
app.use("/api/drivers", driversRouter);
app.use("/api/vehicles", vehiclesRouter);
app.use("/api/trips", tripsRouter);
app.use("/api/locations", locationsRouter);
app.use("/api/maintenance", maintenanceRouter);
app.use("/api/dashboard", dashboardRouter);

// Root Health Check Route
app.get("/health", (_req: Request, res: Response) => {
  res.status(HTTP_STATUS.OK).json({
    status: "ok",
    message: "Backend is running",
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
