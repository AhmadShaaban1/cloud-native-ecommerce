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

router.get('/me', (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'dev-secret'
    );

    res.json({
      email: decoded.email,
      role: 'user'
    });
  } catch (err) {
    return res.status(401).json({ message: 'Invalid token' });
  }
});


// Update profile
router.put('/me', (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'dev-secret'
    );

    // Update user in mock DB (in real app, update in database)
    const userIndex = users.findIndex(u => u.email === decoded.email);
    if (userIndex !== -1) {
      users[userIndex] = { ...users[userIndex], ...req.body };
    }

    res.json({
      message: 'Profile updated',
      user: { email: decoded.email, ...req.body }
    });
  } catch (err) {
    return res.status(401).json({ message: 'Invalid token' });
  }
});

// Change password
router.put('/me/password', (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];
  const { oldPassword, newPassword } = req.body;

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'dev-secret'
    );

    const user = users.find(u => u.email === decoded.email);
    
    if (!user || user.password !== oldPassword) {
      return res.status(401).json({ message: 'Invalid old password' });
    }

    user.password = newPassword;

    res.json({ message: 'Password changed successfully' });
  } catch (err) {
    return res.status(401).json({ message: 'Invalid token' });
  }
});


module.exports = router;
