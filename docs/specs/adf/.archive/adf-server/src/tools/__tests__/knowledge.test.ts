import { describe, it, expect } from "vitest";
import { callTool } from "../../lib/__tests__/test-helper.js";

describe("query_knowledge", () => {
  it("finds entries matching a query", async () => {
    const result = await callTool("query_knowledge", { query: "MCP" });
    expect(result.isError).toBeFalsy();
    expect(result.content[0].text).toContain("KB entries");
  });

  it("returns no matches for nonsense query", async () => {
    const result = await callTool("query_knowledge", {
      query: "zzzznonexistent999xyz",
    });
    expect(result.content[0].text).toContain("No knowledge base entries matched");
  });
});
