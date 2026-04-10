#!/usr/bin/env node

// Safety net: redirect console.log to stderr so stdout stays clean for JSON-RPC
console.log = console.error;

import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { createServer } from "./server.js";

const server = createServer();
const transport = new StdioServerTransport();
await server.connect(transport);
