function extractMarketData() {
  return {
    price: document.querySelector(".price")?.innerText || "0",
    symbol: "BTCUSDT",
    rsi: 60,
    trend: "up"
  };
}