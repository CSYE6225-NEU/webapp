/*
 * Health Check Middleware Tests
 * Tests validation of health check requests
 */

const { validateHealthCheckRequest } = require("../healthCheckMiddleware");

describe("Health Check Middleware", () => {
  let mockRequest;
  let mockResponse;
  let nextFunction;

  beforeEach(() => {
    // Setup mock request
    mockRequest = {
      method: "GET",
      headers: {},
      query: {},
    };

    // Setup mock response
    mockResponse = {
      status: jest.fn().mockReturnThis(),
      set: jest.fn().mockReturnThis(),
      end: jest.fn(),
    };

    // Setup next function
    nextFunction = jest.fn();
  });

  /**
   * Valid Request Tests
   */
  test("should allow valid GET request", () => {
    validateHealthCheckRequest(mockRequest, mockResponse, nextFunction);

    expect(nextFunction).toHaveBeenCalled();
    expect(mockResponse.set).toHaveBeenCalledWith({
      "Cache-Control": "no-cache, no-store, must-revalidate",
      Pragma: "no-cache",
      "X-Content-Type-Options": "nosniff",
    });
  });

  /**
   * Invalid Method Tests
   */
  test("should block non-GET methods", () => {
    mockRequest.method = "POST";

    validateHealthCheckRequest(mockRequest, mockResponse, nextFunction);

    expect(mockResponse.status).toHaveBeenCalledWith(405);
    expect(mockResponse.end).toHaveBeenCalled();
    expect(nextFunction).not.toHaveBeenCalled();
  });

  /**
   * Header Validation Tests
   */
  test("should block requests with authorization header", () => {
    mockRequest.headers.authorization = "Bearer token";

    validateHealthCheckRequest(mockRequest, mockResponse, nextFunction);

    expect(mockResponse.status).toHaveBeenCalledWith(400);
    expect(mockResponse.end).toHaveBeenCalled();
  });

  test("should block requests with non-zero content-length", () => {
    mockRequest.headers["content-length"] = "10";

    validateHealthCheckRequest(mockRequest, mockResponse, nextFunction);

    expect(mockResponse.status).toHaveBeenCalledWith(400);
    expect(mockResponse.end).toHaveBeenCalled();
  });

  /**
   * Query Parameter Tests
   */
  test("should block requests with query parameters", () => {
    mockRequest.query = { param: "value" };

    validateHealthCheckRequest(mockRequest, mockResponse, nextFunction);

    expect(mockResponse.status).toHaveBeenCalledWith(400);
    expect(mockResponse.end).toHaveBeenCalled();
  });

  /**
   * HEAD Request Tests
   */
  test("should block HEAD requests", () => {
    mockRequest.method = "HEAD";

    validateHealthCheckRequest(mockRequest, mockResponse, nextFunction);

    expect(mockResponse.status).toHaveBeenCalledWith(405);
    expect(mockResponse.end).toHaveBeenCalled();
  });
});
