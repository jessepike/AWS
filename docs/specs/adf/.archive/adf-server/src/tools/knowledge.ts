import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import path from "node:path";
import fs from "node:fs";
import { ADF_ROOT, validatePathWithinBase } from "../lib/paths.js";
import { readFile, readFrontmatter } from "../lib/files.js";
import { errorResponse } from "../lib/errors.js";

export function registerKnowledgeTools(server: McpServer): void {
  server.tool(
    "query_knowledge",
    "Search ADF knowledge base entries by topic. Simple text match across KB article titles and content. Use for finding process learnings and design patterns. For rich semantic search, use the Knowledge Base MCP server (when available).",
    {
      query: z.string().describe("Search term or topic"),
    },
    async ({ query }) => {
      const kbDir = path.join(ADF_ROOT, "kb");
      const kbCheck = await validatePathWithinBase(kbDir, ADF_ROOT);
      if (!kbCheck.valid) return errorResponse(kbCheck.error);

      let entries: string[];
      try {
        entries = await fs.promises.readdir(kbCheck.resolved);
      } catch {
        return errorResponse("Could not read kb/ directory.");
      }

      const mdFiles = entries.filter(
        (e) => e.endsWith(".md") && e !== "README.md"
      );

      if (mdFiles.length === 0) {
        return { content: [{ type: "text" as const, text: "No knowledge base entries found." }] };
      }

      const q = query.toLowerCase();
      const matches: Array<{ title: string; snippet: string; path: string }> = [];

      for (const file of mdFiles) {
        const filePath = path.join(kbCheck.resolved, file);
        const fileCheck = await validatePathWithinBase(filePath, ADF_ROOT);
        if (!fileCheck.valid) continue;

        const content = await readFile(fileCheck.resolved);
        const nameMatch = file.toLowerCase().includes(q);
        const contentMatch = content.toLowerCase().includes(q);

        if (!nameMatch && !contentMatch) continue;

        // Extract title from frontmatter or filename
        let title = file.replace(/\.md$/, "");
        try {
          const { data } = await readFrontmatter(fileCheck.resolved);
          if (data.title) title = data.title as string;
        } catch {
          // Use filename as title
        }

        // Extract snippet around first match
        let snippet = "";
        if (contentMatch) {
          const idx = content.toLowerCase().indexOf(q);
          const start = Math.max(0, idx - 80);
          const end = Math.min(content.length, idx + q.length + 80);
          snippet = content.slice(start, end).replace(/\n/g, " ").trim();
          if (start > 0) snippet = "..." + snippet;
          if (end < content.length) snippet = snippet + "...";
        }

        matches.push({ title, snippet, path: filePath });
      }

      if (matches.length === 0) {
        return { content: [{ type: "text" as const, text: `No knowledge base entries matched '${query}'.` }] };
      }

      const lines = matches.map(
        (m) =>
          `- **${m.title}**\n  ${m.snippet ? `> ${m.snippet}\n  ` : ""}Path: ${m.path}`
      );

      return {
        content: [{ type: "text" as const, text: `Found ${matches.length} KB entries:\n\n${lines.join("\n")}` }],
      };
    }
  );
}
