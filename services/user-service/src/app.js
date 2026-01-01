const express = require("express");
const authRoutes = require("./routes/auth");

const app = express();

app.use(express.json());

// Health check (VERY important for Kubernetes)
app.get("/health", (req, res) => {
  res.status(200).json({ status: "UP" });
});

app.use("/api/auth", authRoutes);

module.exports = app;
