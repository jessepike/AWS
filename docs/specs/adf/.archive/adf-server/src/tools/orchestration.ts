import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import path from "node:path";
import { glob } from "node:fs/promises";
import { ADF_ROOT, validatePathWithinBase, normalizePath } from "../lib/paths.js";
import { readFile, readFrontmatter, fileExists } from "../lib/files.js";
import { errorResponse } from "../lib/errors.js";

const STAGE_FILES: Record<string, string> = {
  discover: "ADF-DISCOVER-SPEC.md",
  design: "ADF-DESIGN-SPEC.md",
  develop: "ADF-DEVELOP-SPEC.md",
  deliver: "ADF-DELIVER-SPEC.md",
};

const PROMPT_MAP: Record<string, Record<string, string>> = {
  discover: {
    internal: "prompts/ralph-review-prompt.md",
    external: "prompts/external-review-prompt.md",
  },
  design: {
    internal: "prompts/design-ralph-review-prompt.md",
    external: "prompts/design-external-review-prompt.md",
  },
  develop: {
    internal: "prompts/develop-ralph-review-prompt.md",
    external: "prompts/develop-external-review-prompt.md",
  },
  deliver: {
    internal: "prompts/deliver-ralph-review-prompt.md",
    external: "prompts/deliver-external-review-prompt.md",
  },
};

const TRANSITION_FILES: Record<string, string> = {
  discover_to_design: "prompts/discover-to-design-transition.md",
  design_to_develop: "prompts/design-to-develop-transition.md",
  develop_to_deliver: "prompts/develop-to-deliver-transition.md",
};

export function registerOrchestrationTools(server: McpServer): void {
  server.tool(
    "get_stage",
    "Get ADF stage requirements and workflow. Use when an agent needs to understand what a stage involves, its phases, entry/exit criteria, and expected outputs. Do NOT use for transition guidance (use get_transition_prompt instead).",
    {
      stage: z.enum(["discover", "design", "develop", "deliver"]).describe("ADF stage name"),
    },
    async ({ stage }) => {
      const filePath = path.join(ADF_ROOT, STAGE_FILES[stage]);
      const check = await validatePathWithinBase(filePath, ADF_ROOT);
      if (!check.valid) return errorResponse(check.error);
      if (!(await fileExists(check.resolved)))
        return errorResponse(`Stage spec file not found: ${STAGE_FILES[stage]}`);
      const content = await readFile(check.resolved);
      return { content: [{ type: "text" as const, text: content }] };
    }
  );

  server.tool(
    "get_review_prompt",
    "Get the review prompt for a stage and review phase. Use when preparing to run an internal (Ralph Loop) or external review. Returns the full prompt text ready for use.",
    {
      stage: z.enum(["discover", "design", "develop", "deliver"]).describe("ADF stage"),
      phase: z.enum(["internal", "external"]).describe("Review phase"),
    },
    async ({ stage, phase }) => {
      const relPath = PROMPT_MAP[stage][phase];
      const filePath = path.join(ADF_ROOT, relPath);
      const check = await validatePathWithinBase(filePath, ADF_ROOT);
      if (!check.valid) return errorResponse(check.error);
      if (!(await fileExists(check.resolved)))
        return errorResponse(`Review prompt not found: ${relPath}`);
      const content = await readFile(check.resolved);
      return { content: [{ type: "text" as const, text: content }] };
    }
  );

  server.tool(
    "get_transition_prompt",
    "Get guidance for transitioning between ADF stages. Returns the transition prompt content. Set validate=true to also check prerequisites against the project's current state (reads status.md and brief).",
    {
      transition: z.enum(["discover_to_design", "design_to_develop", "develop_to_deliver"]).describe("Stage transition"),
      project_path: z.string().optional().describe("Project root path. Defaults to cwd."),
      validate: z.boolean().optional().describe("If true, reads project status.md and brief to check prerequisites. Default: false."),
    },
    async ({ transition, project_path, validate }) => {
      const relPath = TRANSITION_FILES[transition];
      const promptPath = path.join(ADF_ROOT, relPath);
      const promptCheck = await validatePathWithinBase(promptPath, ADF_ROOT);
      if (!promptCheck.valid) return errorResponse(promptCheck.error);
      if (!(await fileExists(promptCheck.resolved)))
        return errorResponse(`Transition prompt not found: ${relPath}`);

      const promptContent = await readFile(promptCheck.resolved);

      if (!validate) {
        return { content: [{ type: "text" as const, text: promptContent }] };
      }

      // Validate mode: read status.md and brief
      const projectRoot = normalizePath(project_path || process.cwd());

      // Read status.md
      const statusPath = path.join(projectRoot, "status.md");
      const statusCheck = await validatePathWithinBase(statusPath, projectRoot);
      if (!statusCheck.valid) return errorResponse(statusCheck.error);
      if (!(await fileExists(statusCheck.resolved)))
        return errorResponse("Cannot validate: status.md not found in project.");
      const { data: statusData } = await readFrontmatter(statusCheck.resolved);

      // Resolve brief: docs/brief.md first, then glob docs/inbox/*-brief.md
      let briefContent = "";
      const briefPath = path.join(projectRoot, "docs", "brief.md");
      const briefCheck = await validatePathWithinBase(briefPath, projectRoot);
      if (briefCheck.valid && await fileExists(briefCheck.resolved)) {
        briefContent = await readFile(briefCheck.resolved);
      } else {
        // Glob fallback
        const inboxPattern = path.join(projectRoot, "docs", "inbox", "*-brief.md");
        const matches: string[] = [];
        for await (const entry of glob(inboxPattern)) {
          matches.push(entry);
        }
        if (matches.length === 0) {
          return errorResponse("Cannot validate: no brief found at docs/brief.md or docs/inbox/*-brief.md.");
        }
        if (matches.length > 1) {
          return errorResponse(`Cannot validate: multiple brief candidates found in docs/inbox/. Expected one, found ${matches.length}: ${matches.map(m => path.basename(m)).join(", ")}`);
        }
        const matchCheck = await validatePathWithinBase(matches[0], projectRoot);
        if (!matchCheck.valid) return errorResponse(matchCheck.error);
        briefContent = await readFile(matchCheck.resolved);
      }

      // Build validation summary
      const lines: string[] = [];
      lines.push("## Transition Validation");
      lines.push("");
      lines.push(`**Transition:** ${transition.replace("_", " → ")}`);
      lines.push(`**Status.md stage:** ${statusData.stage || "not set"}`);
      lines.push(`**Status.md phase:** ${statusData.phase || "not set"}`);
      lines.push(`**Status.md status:** ${statusData.status || "not set"}`);
      lines.push("");

      // Check prerequisites based on transition
      const issues: string[] = [];
      if (transition === "discover_to_design") {
        if (statusData.stage !== "discover") issues.push(`Expected stage 'discover', got '${statusData.stage}'`);
      } else if (transition === "design_to_develop") {
        if (statusData.stage !== "design") issues.push(`Expected stage 'design', got '${statusData.stage}'`);
      } else if (transition === "develop_to_deliver") {
        if (statusData.stage !== "develop") issues.push(`Expected stage 'develop', got '${statusData.stage}'`);
      }

      if (issues.length === 0) {
        lines.push("**Prerequisites:** ✓ Met");
      } else {
        lines.push("**Prerequisites:** ✗ Not met");
        for (const issue of issues) {
          lines.push(`- ${issue}`);
        }
      }

      lines.push("");
      lines.push("---");
      lines.push("");
      lines.push(promptContent);

      return { content: [{ type: "text" as const, text: lines.join("\n") }] };
    }
  );
}
