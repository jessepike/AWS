import { describe, it, expect } from "vitest";
import { callTool } from "../../lib/__tests__/test-helper.js";
import { ADF_ROOT } from "../../lib/paths.js";

describe("get_project_type_guidance", () => {
  it("returns guidance for app type", async () => {
    const result = await callTool("get_project_type_guidance", { type: "app" });
    expect(result.isError).toBeFalsy();
    expect(result.content[0].text).toContain("app");
  });
});

describe("check_project_structure", () => {
  it("checks ADF repo structure", async () => {
    const result = await callTool("check_project_structure", {
      project_path: ADF_ROOT,
    });
    expect(result.isError).toBeFalsy();
    expect(result.content[0].text).toContain("Project Structure Check");
    expect(result.content[0].text).toContain("✓");
  });
});

describe("check_project_health", () => {
  it("runs health check on ADF repo", async () => {
    const result = await callTool("check_project_health", {
      project_path: ADF_ROOT,
    });
    expect(result.isError).toBeFalsy();
    expect(result.content[0].text).toContain("Project Health Check");
    expect(result.content[0].text).toContain("File Presence");
    expect(result.content[0].text).toContain("Frontmatter Validation");
    expect(result.content[0].text).toContain("Required Sections");
  });
});
