function buildPrompt(data) {
  return `
Analyze market data and return trading signal JSON.

DATA:
${JSON.stringify(data, null, 2)}
`;
}

module.exports = { buildPrompt };