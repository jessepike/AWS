import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import path from "node:path";
import { ADF_ROOT, validatePathWithinBase, normalizePath } from "../lib/paths.js";
import { readFile, readFrontmatter, fileExists } from "../lib/files.js";
import { errorResponse } from "../lib/errors.js";

// Per design.md — check_project_structure items
const STRUCTURE_ITEMS = [
  ".claude/CLAUDE.md",
  ".claude/rules/",
  "docs/",
  "docs/intent.md",
  "docs/brief.md",
  "docs/inbox/",
  ".archive/",
  "README.md",
];

// Per design.md — check_project_health required sections
// Uses regex header check (/^#+\s+SectionName/m), not string inclusion
const HEALTH_SECTIONS: Record<string, { file: string; sections: string[] }> = {
  brief: {
    file: "docs/brief.md",
    sections: ["Summary", "Scope", "Success Criteria", "Constraints", "Decisions"],
  },
  intent: {
    file: "docs/intent.md",
    // Per ADF-INTENT-SPEC
    sections: ["Problem", "Outcome", "Why It Matters"],
  },
  status: {
    file: "status.md",
    sections: ["Current State"],
  },
  claude_md: {
    file: ".claude/CLAUDE.md",
    sections: ["Context Map", "Orientation"],
  },
};

function hasSection(content: string, sectionName: string): boolean {
  const regex = new RegExp(`^#+\\s+${sectionName}`, "m");
  return regex.test(content);
}

export function registerProjectTools(server: McpServer): void {
  server.tool(
    "get_project_type_guidance",
    "Get ADF guidance for a project type classification. Use during Discover or Design to understand what outputs, review focus, and structure a project type requires.",
    {
      type: z.enum(["app", "workflow", "artifact"]).describe("Project type"),
      scale: z.enum(["personal", "commercial"]).optional().describe("Project scale modifier"),
      scope: z.enum(["mvp", "full"]).optional().describe("Project scope modifier"),
    },
    async ({ type, scale, scope }) => {
      const filePath = path.join(ADF_ROOT, "ADF-PROJECT-TYPES-SPEC.md");
      const check = await validatePathWithinBase(filePath, ADF_ROOT);
      if (!check.valid) return errorResponse(check.error);
      if (!(await fileExists(check.resolved)))
        return errorResponse("ADF-PROJECT-TYPES-SPEC.md not found.");
      const content = await readFile(check.resolved);

      const lines: string[] = [`## Project Type Guidance: ${type}`];
      if (scale) lines[0] += ` · ${scale}`;
      if (scope) lines[0] += ` · ${scope}`;
      lines.push("");
      lines.push(content);

      return { content: [{ type: "text" as const, text: lines.join("\n") }] };
    }
  );

  server.tool(
    "check_project_structure",
    "Validate a project's folder structure against ADF spec. Checks for required directories and files. Use when auditing a project or after scaffolding.",
    {
      project_path: z.string().optional().describe("Project root path. Defaults to cwd."),
    },
    async ({ project_path }) => {
      const projectRoot = normalizePath(project_path || process.cwd());
      const results: string[] = [`Project Structure Check: ${projectRoot}`];
      let passed = 0;
      let total = STRUCTURE_ITEMS.length;

      for (const item of STRUCTURE_ITEMS) {
        const itemPath = path.join(projectRoot, item);
        const check = await validatePathWithinBase(itemPath, projectRoot);
        if (!check.valid) {
          results.push(`✗ ${item} — sandbox error`);
          continue;
        }
        if (await fileExists(check.resolved)) {
          results.push(`✓ ${item}`);
          passed++;
        } else {
          results.push(`✗ ${item} — missing`);
        }
      }

      results.push("");
      const missing = STRUCTURE_ITEMS.filter(
        (_item, i) => results[i + 1].startsWith("✗")
      ).join(", ");
      results.push(`Result: ${passed}/${total} passed.${missing ? ` Missing: ${missing}` : ""}`);

      return { content: [{ type: "text" as const, text: results.join("\n") }] };
    }
  );

  server.tool(
    "check_project_health",
    "Run structural health checks on an ADF project. Checks file presence, frontmatter validity, and required sections in key artifacts. Does NOT perform semantic analysis. Use for project audits or pre-review validation.",
    {
      project_path: z.string().optional().describe("Project root path. Defaults to cwd."),
    },
    async ({ project_path }) => {
      const projectRoot = normalizePath(project_path || process.cwd());
      const lines: string[] = [`Project Health Check: ${projectRoot}`, ""];

      // 1. File presence
      lines.push("### File Presence");
      let presencePass = 0;
      for (const item of STRUCTURE_ITEMS) {
        const itemPath = path.join(projectRoot, item);
        const check = await validatePathWithinBase(itemPath, projectRoot);
        if (check.valid && await fileExists(check.resolved)) {
          lines.push(`✓ ${item}`);
          presencePass++;
        } else {
          lines.push(`✗ ${item} — missing`);
        }
      }
      lines.push("");

      // 2. Frontmatter validation
      lines.push("### Frontmatter Validation");
      const fmFiles = ["docs/intent.md", "docs/brief.md", "status.md", ".claude/CLAUDE.md"];
      for (const relFile of fmFiles) {
        const filePath = path.join(projectRoot, relFile);
        const check = await validatePathWithinBase(filePath, projectRoot);
        if (!check.valid || !(await fileExists(check.resolved))) {
          lines.push(`✗ ${relFile} — file missing`);
          continue;
        }
        try {
          const { data } = await readFrontmatter(check.resolved);
          if (Object.keys(data).length > 0) {
            lines.push(`✓ ${relFile} — valid frontmatter`);
          } else {
            lines.push(`✗ ${relFile} — no frontmatter`);
          }
        } catch {
          lines.push(`✗ ${relFile} — invalid frontmatter`);
        }
      }
      lines.push("");

      // 3. Required sections
      // Per design.md: regex header check, not string inclusion
      // Per ADF-*-SPEC versions (add spec version comments during implementation)
      lines.push("### Required Sections");
      for (const [key, config] of Object.entries(HEALTH_SECTIONS)) {
        const filePath = path.join(projectRoot, config.file);
        const check = await validatePathWithinBase(filePath, projectRoot);
        if (!check.valid || !(await fileExists(check.resolved))) {
          lines.push(`✗ ${config.file} — file missing, cannot check sections`);
          continue;
        }
        const content = await readFile(check.resolved);
        for (const section of config.sections) {
          if (key === "claude_md") {
            // CLAUDE.md needs either "Context Map" OR "Orientation"
            if (section === "Context Map") {
              if (hasSection(content, "Context Map") || hasSection(content, "Orientation")) {
                lines.push(`✓ ${config.file} — has Context Map or Orientation`);
              } else {
                lines.push(`✗ ${config.file} — missing Context Map or Orientation`);
              }
            }
            // Skip the "Orientation" entry since we handle it above
            if (section === "Orientation") continue;
          } else {
            if (hasSection(content, section)) {
              lines.push(`✓ ${config.file} — has ${section}`);
            } else {
              lines.push(`✗ ${config.file} — missing ${section}`);
            }
          }
        }
      }

      lines.push("");
      lines.push("---");
      lines.push(`File presence: ${presencePass}/${STRUCTURE_ITEMS.length}`);

      return { content: [{ type: "text" as const, text: lines.join("\n") }] };
    }
  );
}
