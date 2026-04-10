import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { registerOrchestrationTools } from "./tools/orchestration.js";
import { registerArtifactTools } from "./tools/artifacts.js";
import { registerProjectTools } from "./tools/project.js";
import { registerGovernanceTools } from "./tools/governance.js";
import { registerCapabilitiesTools } from "./tools/capabilities.js";
import { registerKnowledgeTools } from "./tools/knowledge.js";

export function createServer(): McpServer {
  const server = new McpServer({
    name: "adf",
    version: "1.0.0",
  });

  registerOrchestrationTools(server);
  registerArtifactTools(server);
  registerProjectTools(server);
  registerGovernanceTools(server);
  registerCapabilitiesTools(server);
  registerKnowledgeTools(server);

  return server;
}
