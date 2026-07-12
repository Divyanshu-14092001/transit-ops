import dotenv from "dotenv";
import app from "./app";

// Load Environment Variables
dotenv.config();

const PORT = Number(process.env.PORT) || 3000;

function startServer() {
  try {
    const server = app.listen(PORT, "0.0.0.0", () => {
      // eslint-disable-next-line no-console
      console.log(`[TransitOps Server] Running on http://localhost:${PORT}`);
    });

    // Graceful Shutdown Handler
    const shutdown = () => {
      // eslint-disable-next-line no-console
      console.log("Shutting down backend server gracefully...");
      server.close(() => {
        // eslint-disable-next-line no-console
        console.log("Backend server closed.");
        process.exit(0);
      });
    };

    process.on("SIGTERM", shutdown);
    process.on("SIGINT", shutdown);
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error("Failed to start backend server:", error);
    process.exit(1);
  }
}

startServer();
