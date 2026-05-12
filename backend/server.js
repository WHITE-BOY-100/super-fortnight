const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();

app.use(cors());
app.use(express.json());

// ROOT route
app.get("/", (req, res) => {
  res.json({ status: "AI Signal Backend Running" });
});

// HEALTH route (THIS IS IMPORTANT)
app.get("/test-route-123", (req, res) => {
  res.json({ ok: "it works" });
});

// test route
app.get("/test", (req, res) => {
  res.json({ ok: true });
});

const PORT = process.env.PORT || 8080;

app.listen(PORT, "0.0.0.0", () => {
  console.log("🚀 Server running on " + PORT);
});
