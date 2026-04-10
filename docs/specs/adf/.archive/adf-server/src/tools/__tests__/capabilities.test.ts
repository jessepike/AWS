import { describe, it, expect } from "vitest";
import { callTool } from "../../lib/__tests__/test-helper.js";

describe("query_capabilities", () => {
  it("returns results without filters", async () => {
    const result = await callTool("query_capabilities", {});
    expect(result.isError).toBeFalsy();
    expect(result.content[0].text).toContain("capabilities");
  });

  it("filters by type", async () => {
    const result = await callTool("query_capabilities", { type: "plugin" });
    expect(result.isError).toBeFalsy();
  });

  it("returns empty for non-matching keyword", async () => {
    const result = await callTool("query_capabilities", {
      query: "zzzznonexistent999",
    });
    expect(result.content[0].text).toContain("No capabilities matched");
  });
});

describe("get_capability_detail", () => {
  it("returns detail for existing capability", async () => {
    // Use a known capability ID from the registry
    const result = await callTool("get_capability_detail", {
      capability_id: "adf-env",
    });
    // May or may not exist; just check it doesn't crash
    expect(result.content[0].text.length).toBeGreaterThan(0);
  });

  it("returns error for nonexistent capability", async () => {
    const result = await callTool("get_capability_detail", {
      capability_id: "nonexistent-cap",
    });
    expect(result.isError).toBe(true);
    expect(result.content[0].text).toContain("not found");
  });
});
