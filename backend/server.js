const express = require("express");
const cors = require("cors");
require("dotenv").config();

const analyzeRoute = require("./routes/analyze");

console.log("GROQ =", process.env.GROQ_API_KEY);

const app = express();

app.use(cors());
app.use(express.json());

// Health check route
app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

// Analyze route
app.use("/analyze", analyzeRoute);

const PORT = process.env.PORT || 5000;

app.listen(PORT, "0.0.0.0", () => {
  console.log("Server running on port " + PORT);
});
