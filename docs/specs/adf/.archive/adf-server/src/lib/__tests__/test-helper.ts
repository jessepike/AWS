import { createServer } from "../../server.js";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";

let _server: McpServer | null = null;

export function getServer(): McpServer {
  if (!_server) {
    _server = createServer();
  }
  return _server;
}

export async function callTool(
  name: string,
  args: Record<string, unknown> = {}
): Promise<{ content: Array<{ type: string; text: string }>; isError?: boolean }> {
  const server = getServer();
  const tools = (server as any)._registeredTools;
  const tool = tools[name];
  if (!tool) throw new Error(`Tool '${name}' not found`);
  return tool.handler(args, {});
}
