import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import path from "node:path";
import { REGISTRY_ROOT, validatePathWithinBase } from "../lib/paths.js";
import { readFile, fileExists } from "../lib/files.js";
import { errorResponse } from "../lib/errors.js";

interface CapabilityEntry {
  id: string;
  name: string;
  type: string;
  description: string;
  tags: string[];
  install_level?: string;
}

export function registerCapabilitiesTools(server: McpServer): void {
  server.tool(
    "query_capabilities",
    "Search the capabilities registry by keyword, type, or tags. Use when an agent needs to find available tools, skills, agents, or plugins for a task. Returns matching capability summaries.",
    {
      query: z.string().optional().describe("Keyword search across name, description, tags"),
      type: z.enum(["skill", "tool", "agent", "plugin"]).optional().describe("Filter by capability type"),
      tags: z.array(z.string()).optional().describe("Filter by tags (AND logic)"),
    },
    async ({ query, type, tags }) => {
      const inventoryPath = path.join(REGISTRY_ROOT, "inventory.json");
      const check = await validatePathWithinBase(inventoryPath, REGISTRY_ROOT);
      if (!check.valid) return errorResponse(check.error);
      if (!(await fileExists(check.resolved)))
        return errorResponse("Capabilities inventory.json not found.");

      const raw = await readFile(check.resolved);
      let entries: CapabilityEntry[];
      try {
        const parsed = JSON.parse(raw);
        // inventory.json may be { capabilities: [...] } or a plain array
        entries = Array.isArray(parsed) ? parsed : parsed.capabilities;
        if (!Array.isArray(entries)) {
          return errorResponse("inventory.json has unexpected format.");
        }
      } catch {
        return errorResponse("Failed to parse inventory.json.");
      }

      // Filter by type
      if (type) {
        entries = entries.filter((e) => e.type === type);
      }

      // Filter by tags (AND logic)
      if (tags && tags.length > 0) {
        entries = entries.filter((e) =>
          tags.every((t) => e.tags?.includes(t))
        );
      }

      // Filter by keyword
      if (query) {
        const q = query.toLowerCase();
        entries = entries.filter(
          (e) =>
            e.name?.toLowerCase().includes(q) ||
            e.description?.toLowerCase().includes(q) ||
            e.tags?.some((t) => t.toLowerCase().includes(q))
        );
      }

      if (entries.length === 0) {
        return { content: [{ type: "text" as const, text: "No capabilities matched the query." }] };
      }

      const lines = entries.map(
        (e) =>
          `- **${e.name}** (${e.type}) — ${e.description}${e.tags?.length ? `\n  Tags: ${e.tags.join(", ")}` : ""}`
      );

      return {
        content: [{ type: "text" as const, text: `Found ${entries.length} capabilities:\n\n${lines.join("\n")}` }],
      };
    }
  );

  server.tool(
    "get_capability_detail",
    "Get full details for a specific capability by ID. Use when you need installation instructions, configuration, or complete metadata for a capability found via query_capabilities.",
    {
      capability_id: z
        .string()
        .regex(/^[a-z0-9][a-z0-9-]*$/)
        .describe("Capability ID (e.g., 'adf-env', 'claude-md-management'). Must match pattern: lowercase alphanumeric with hyphens."),
    },
    async ({ capability_id }) => {
      const capPath = path.join(REGISTRY_ROOT, "capabilities", capability_id, "capability.yaml");
      const check = await validatePathWithinBase(capPath, REGISTRY_ROOT);
      if (!check.valid) return errorResponse(check.error);
      if (!(await fileExists(check.resolved)))
        return errorResponse(`Capability '${capability_id}' not found. Use query_capabilities to search for available capabilities.`);
      const content = await readFile(check.resolved);
      return { content: [{ type: "text" as const, text: content }] };
    }
  );
}
