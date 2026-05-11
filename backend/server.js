const express = require("express");
const cors = require("cors");
require("dotenv").config();

const analyzeRoute = require("./routes/analyze");

console.log("GROQ =", process.env.GROQ_API_KEY);

const express = require("express");
const app = express();

app.use(express.json());

// ✅ ADD THIS ROUTE
app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

// your other routes
app.use("/analyze", require("./routes/analyze"));

const PORT = process.env.PORT || 3000;

app.listen(PORT, "0.0.0.0", () => {
  console.log("Server running on port " + PORT);
});

