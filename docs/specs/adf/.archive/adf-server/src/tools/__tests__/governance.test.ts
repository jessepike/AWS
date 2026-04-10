import { describe, it, expect } from "vitest";
import { callTool } from "../../lib/__tests__/test-helper.js";

describe("get_rules_spec", () => {
  it("returns rules spec content", async () => {
    const result = await callTool("get_rules_spec");
    expect(result.isError).toBeFalsy();
    expect(result.content[0].text).toContain("Rules");
  });
});

describe("get_context_spec", () => {
  it("returns global spec", async () => {
    const result = await callTool("get_context_spec", { level: "global" });
    expect(result.isError).toBeFalsy();
    expect(result.content[0].text.length).toBeGreaterThan(100);
  });

  it("returns project spec", async () => {
    const result = await callTool("get_context_spec", { level: "project" });
    expect(result.isError).toBeFalsy();
    expect(result.content[0].text.length).toBeGreaterThan(100);
  });
});
