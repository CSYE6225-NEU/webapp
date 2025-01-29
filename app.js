const express = require("express");
const app = express();

const port = process.env.PORT || 8080;

app.get("/test", (req, res) => {
  res.status(200).json({ message: `test api working` });
});

app.listen(port, () => {
  console.log(`server is running on ${port}`);
});
