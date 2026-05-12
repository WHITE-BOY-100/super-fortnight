const express = require("express");
const cors = require("cors");
require("dotenv").config();

const analyzeRoute = require("./routes/analyze");

const app = express();

app.use(cors());
app.use(express.json());

// ✅ Root route
app.get("/", (req, res) => {
  res.json({
    status: "AI Signal Backend Running"
  });
});

// ✅ Health check route
app.get("/health", (req, res) => {
  res.json({
    status: "ok"
  });
});

// API routes
app.use("/analyze", analyzeRoute);

// Port
const PORT = process.env.PORT || 8080;

app.listen(PORT, "0.0.0.0", () => {
  console.log("🚀 Server running on " + PORT);
});
