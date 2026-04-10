import { describe, it, expect } from "vitest";
import { callTool } from "../../lib/__tests__/test-helper.js";

describe("get_artifact_spec", () => {
  const artifacts = [
    "brief", "intent", "status", "readme", "context",
    "rules", "design", "backlog", "tasks", "folder_structure",
    "project_types", "stages", "review",
  ];

  for (const artifact of artifacts) {
    it(`returns spec for ${artifact}`, async () => {
      const result = await callTool("get_artifact_spec", { artifact });
      expect(result.isError).toBeFalsy();
      expect(result.content[0].text.length).toBeGreaterThan(100);
    });
  }
});

describe("get_artifact_stub", () => {
  for (const artifact of ["brief", "intent", "status", "tasks", "rules_constraints"]) {
    it(`returns stub for ${artifact}`, async () => {
      const result = await callTool("get_artifact_stub", { artifact });
      expect(result.isError).toBeFalsy();
      expect(result.content[0].text.length).toBeGreaterThan(10);
    });
  }

  it("returns claude_md stub defaulting to app", async () => {
    const result = await callTool("get_artifact_stub", { artifact: "claude_md" });
    expect(result.isError).toBeFalsy();
  });

  for (const project_type of ["app", "workflow", "artifact"]) {
    it(`returns claude_md stub for ${project_type}`, async () => {
      const result = await callTool("get_artifact_stub", {
        artifact: "claude_md",
        project_type,
      });
      expect(result.isError).toBeFalsy();
    });
  }
});
