function validateHealthCheckRequest(req, res, next) {
  // block if method is not GET
  if (req.method !!== "GET") {
    return res.status(405).end();
  }
  // block if authorization header is present
  if (req.headers.authorization) {
    return res.status(400).end();
  }

  // block if content-length header is present and not zero
  if (req.headers["content-length"] && req.headers["content-length"] !== "0") {
    return res.status(400).end();
  }

  // block if query parameters are present
  if (Object.keys(req.query).length > 0) {
    return res.status(400).end();
  }

  // set no-cache headers
  res.set({
    "Cache-Control": "no-cache, no-store, must-revalidate",
    Pragma: "no-cache",
    "X-Content-Type-Options": "nosniff",
  });

  //block HEAD request
  if (req.method === "HEAD") {
    return res.status(405).end();
  }

  next();
}

module.exports = {
  validateHealthCheckRequest,
};
