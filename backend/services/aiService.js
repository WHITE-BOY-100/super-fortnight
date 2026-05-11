const axios = require("axios");

async function getAIAnalysis(data) {
  const prompt = `
You are a professional trading signal engine.

Return ONLY JSON:
{
  "signal": "BUY | SELL | WAIT",
  "confidence": 0-100,
  "reason": ""
}

DATA:
${JSON.stringify(data, null, 2)}
`;

  const response = await axios.post(
    "https://api.openai.com/v1/chat/completions",
    {
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      temperature: 0.3
    },
    {
      headers: {
        Authorization: `Bearer ${process.env.OPENAI_KEY}`,
        "Content-Type": "application/json"
      }
    }
  );

  return response.data.choices[0].message.content;
}

module.exports = { getAIAnalysis };