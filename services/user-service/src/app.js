const express = require("express");
const authRoutes = require("./routes/auth");
const userRoutes = require("./routes/users");

const app = express();

app.use(express.json());

// Health check (VERY important for Kubernetes)
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "UP",
    timestamp: new Date().toISOString(),
    service: "user-service"
  });
});

app.get("/api/auth/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    service: "user-service",
    timestamp: new Date().toISOString()
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);

module.exports = app;
