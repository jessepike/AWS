import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import path from "node:path";
import { ADF_ROOT, validatePathWithinBase } from "../lib/paths.js";
import { readFile, fileExists } from "../lib/files.js";
import { errorResponse } from "../lib/errors.js";

// Per design.md Section "Tool Schemas > Artifacts"
const SPEC_MAP: Record<string, string> = {
  brief: "ADF-BRIEF-SPEC.md",
  intent: "ADF-INTENT-SPEC.md",
  status: "ADF-STATUS-SPEC.md",
  readme: "ADF-README-SPEC.md",
  context: "ADF-CONTEXT-ARTIFACT-SPEC.md",
  rules: "ADF-RULES-SPEC.md",
  design: "ADF-DESIGN-SPEC.md",
  backlog: "ADF-BACKLOG-SPEC.md",
  tasks: "ADF-TASKS-SPEC.md",
  folder_structure: "ADF-FOLDER-STRUCTURE-SPEC.md",
  project_types: "ADF-PROJECT-TYPES-SPEC.md",
  stages: "ADF-STAGES-SPEC.md",
  review: "ADF-REVIEW-SPEC.md",
};

const STUB_MAP: Record<string, string> = {
  brief: "stubs/brief.md",
  intent: "stubs/intent.md",
  status: "stubs/status.md",
  tasks: "stubs/tasks.md",
  rules_constraints: "stubs/rules-constraints.md",
  // claude_md handled separately
};

export function registerArtifactTools(server: McpServer): void {
  server.tool(
    "get_artifact_spec",
    "Get the ADF specification for an artifact type. Use when you need to understand what a valid artifact looks like — required sections, frontmatter, formatting rules.",
    {
      artifact: z.enum([
        "brief", "intent", "status", "readme", "context",
        "rules", "design", "backlog", "tasks", "folder_structure",
        "project_types", "stages", "review",
      ]).describe("Artifact type"),
    },
    async ({ artifact }) => {
      const fileName = SPEC_MAP[artifact];
      const filePath = path.join(ADF_ROOT, fileName);
      const check = await validatePathWithinBase(filePath, ADF_ROOT);
      if (!check.valid) return errorResponse(check.error);
      if (!(await fileExists(check.resolved)))
        return errorResponse(`Spec file not found: ${fileName}`);
      const content = await readFile(check.resolved);
      return { content: [{ type: "text" as const, text: content }] };
    }
  );

  server.tool(
    "get_artifact_stub",
    "Get a starter template for an ADF artifact. Use when initializing a new project or creating a new artifact. Returns the template with placeholder values ready to fill in.",
    {
      artifact: z.enum([
        "brief", "intent", "status", "tasks", "rules_constraints", "claude_md",
      ]).describe("Artifact to get stub for"),
      project_type: z.enum(["app", "workflow", "artifact"]).optional().describe("Project type — used to select the correct claude_md stub. Defaults to 'app'. Ignored for non-claude_md artifacts."),
    },
    async ({ artifact, project_type }) => {
      let relPath: string;
      if (artifact === "claude_md") {
        const pt = project_type || "app";
        relPath = `stubs/claude-md/${pt}.md`;
      } else {
        relPath = STUB_MAP[artifact];
      }

      const filePath = path.join(ADF_ROOT, relPath);
      const check = await validatePathWithinBase(filePath, ADF_ROOT);
      if (!check.valid) return errorResponse(check.error);
      if (!(await fileExists(check.resolved)))
        return errorResponse(`Stub file not found: ${relPath}`);
      const content = await readFile(check.resolved);
      return { content: [{ type: "text" as const, text: content }] };
    }
  );
}
