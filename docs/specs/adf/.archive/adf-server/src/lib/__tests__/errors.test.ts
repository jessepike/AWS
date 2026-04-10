import { describe, it, expect } from "vitest";
import { errorResponse } from "../errors.js";

describe("errorResponse", () => {
  it("returns MCP isError format", () => {
    const result = errorResponse("something failed");
    expect(result).toEqual({
      content: [{ type: "text", text: "something failed" }],
      isError: true,
    });
  });
});
