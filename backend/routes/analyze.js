const express = require("express");
const router = express.Router();
const { getAIAnalysis } = require("../services/aiService");

router.post("/", async (req, res) => {
  try {
    const data = req.body;

    const result = await getAIAnalysis(data);

    res.json({
      success: true,
      result
    });

  } catch (err) {
    res.json({
      success: false,
      error: err.message
    });
  }
});

module.exports = router;