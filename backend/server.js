const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
require("dotenv").config();

const { initializeDatabase, testConnection } = require("./config/database");
const authRoutes = require("./routes/auth");

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: "cross-origin" },
  })
);

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: "Too many requests from this IP, please try again later.",
  },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(limiter);

// CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);

    const allowedOrigins = process.env.CORS_ORIGIN
      ? process.env.CORS_ORIGIN.split(",")
      : ["http://localhost:3001", "http://127.0.0.1:3001"];

    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With"],
};

app.use(cors(corsOptions));

// Body parsing middleware
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Request logging middleware
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`${timestamp} - ${req.method} ${req.path} - IP: ${req.ip}`);
  next();
});

// Health check endpoint
app.get("/health", async (req, res) => {
  try {
    const dbStatus = await testConnection();
    res.json({
      success: true,
      message: "Server is running",
      timestamp: new Date().toISOString(),
      database: dbStatus ? "connected" : "disconnected",
      environment: process.env.NODE_ENV || "development",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server health check failed",
      error: error.message,
    });
  }
});

// API routes
app.use("/api/auth", authRoutes);

// Welcome endpoint
app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Welcome to Ikiraha API",
    version: "1.0.0",
    documentation: "/api/docs",
    endpoints: {
      auth: "/api/auth",
      health: "/health",
    },
  });
});

// 404 handler
app.use("*", (req, res) => {
  res.status(404).json({
    success: false,
    message: "Endpoint not found",
    path: req.originalUrl,
    method: req.method,
  });
});

// Global error handler
app.use((error, req, res, next) => {
  console.error("Global error handler:", error);

  // Handle CORS errors
  if (error.message === "Not allowed by CORS") {
    return res.status(403).json({
      success: false,
      message: "CORS policy violation",
    });
  }

  // Handle JSON parsing errors
  if (error instanceof SyntaxError && error.status === 400 && "body" in error) {
    return res.status(400).json({
      success: false,
      message: "Invalid JSON format",
    });
  }

  // Default error response
  res.status(error.status || 500).json({
    success: false,
    message:
      process.env.NODE_ENV === "production"
        ? "Internal server error"
        : error.message,
    ...(process.env.NODE_ENV !== "production" && { stack: error.stack }),
  });
});

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM received, shutting down gracefully");
  process.exit(0);
});

process.on("SIGINT", () => {
  console.log("SIGINT received, shutting down gracefully");
  process.exit(0);
});

// Start server
const startServer = async () => {
  try {
    // Initialize database
    console.log("🔄 Initializing database...");
    await initializeDatabase();

    // Start server
    app.listen(PORT, () => {
      console.log("🚀 Server started successfully!");
      console.log(`📍 Server running on port ${PORT}`);
      console.log(`🌍 Environment: ${process.env.NODE_ENV || "development"}`);
      console.log(`🔗 API Base URL: http://localhost:${PORT}`);
      console.log(`❤️  Health Check: http://localhost:${PORT}/health`);
      console.log(`🔐 Auth Endpoints: http://localhost:${PORT}/api/auth`);
      console.log("📚 Ready to accept requests!");
    });
  } catch (error) {
    console.error("❌ Failed to start server:", error.message);
    process.exit(1);
  }
};

// Start the server
startServer();
