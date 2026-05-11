let extractedData = {
  symbol: "BTCUSDT",
  price: 67000,
  rsi: 55,
  trend: "up"
};

document.getElementById("scan").onclick = () => {
  document.getElementById("output").innerText =
    JSON.stringify(extractedData, null, 2);
};

document.getElementById("analyze").onclick = async () => {
  const res = await fetch("http://localhost:5000/api/analyze", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(extractedData)
  });

  const data = await res.json();

  document.getElementById("output").innerText =
    JSON.stringify(data, null, 2);
};