import { describe, it, expect } from "vitest";
import { callTool } from "../../lib/__tests__/test-helper.js";

describe("get_stage", () => {
  for (const stage of ["discover", "design", "develop"]) {
    it(`returns content for ${stage}`, async () => {
      const result = await callTool("get_stage", { stage });
      expect(result.isError).toBeFalsy();
      expect(result.content[0].text.length).toBeGreaterThan(100);
    });
  }
});

describe("get_review_prompt", () => {
  for (const stage of ["discover", "design", "develop"]) {
    for (const phase of ["internal", "external"]) {
      it(`returns prompt for ${stage}/${phase}`, async () => {
        const result = await callTool("get_review_prompt", { stage, phase });
        expect(result.isError).toBeFalsy();
        expect(result.content[0].text.length).toBeGreaterThan(50);
      });
    }
  }
});

describe("get_transition_prompt", () => {
  it("returns prompt without validation", async () => {
    const result = await callTool("get_transition_prompt", {
      transition: "discover_to_design",
    });
    expect(result.isError).toBeFalsy();
    expect(result.content[0].text.length).toBeGreaterThan(50);
  });

  it("returns prompt for design_to_develop", async () => {
    const result = await callTool("get_transition_prompt", {
      transition: "design_to_develop",
    });
    expect(result.isError).toBeFalsy();
  });

  it("validates against ADF project (which has status.md)", async () => {
    const { ADF_ROOT } = await import("../../lib/paths.js");
    const result = await callTool("get_transition_prompt", {
      transition: "design_to_develop",
      project_path: ADF_ROOT,
      validate: true,
    });
    // ADF project has status.md, should return validation info
    expect(result.content[0].text).toContain("Transition Validation");
  });
});
