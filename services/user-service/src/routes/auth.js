const express = require("express");
const jwt = require("jsonwebtoken");

const router = express.Router();

// Mock users DB
const users = [];

// Register
router.post("/register", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Missing fields" });
  }

  users.push({ email, password });
  return res.status(201).json({ message: "User registered" });
});

// Login
router.post("/login", (req, res) => {
  const { email, password } = req.body;

  const user = users.find(
    (u) => u.email === email && u.password === password
  );

  if (!user) {
    return res.status(401).json({ message: "Invalid credentials" });
  }

  const token = jwt.sign(
    { email },
    process.env.JWT_SECRET || "dev-secret",
    { expiresIn: "1h" }
  );

  res.json({ token });
});

module.exports = router;
