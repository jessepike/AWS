import { describe, it, expect } from "vitest";
import path from "node:path";
import { readFile, readFrontmatter, fileExists } from "../files.js";
import { ADF_ROOT } from "../paths.js";

describe("readFile", () => {
  it("reads an existing file", async () => {
    const content = await readFile(path.join(ADF_ROOT, "ADF-RULES-SPEC.md"));
    expect(content).toContain("Rules");
  });

  it("throws on missing file", async () => {
    await expect(readFile("/nonexistent")).rejects.toThrow();
  });
});

describe("readFrontmatter", () => {
  it("parses YAML frontmatter", async () => {
    const { data, content } = await readFrontmatter(
      path.join(ADF_ROOT, "ADF-RULES-SPEC.md")
    );
    expect(data).toBeDefined();
    expect(typeof content).toBe("string");
  });
});

describe("fileExists", () => {
  it("returns true for existing file", async () => {
    expect(await fileExists(path.join(ADF_ROOT, "ADF-RULES-SPEC.md"))).toBe(true);
  });

  it("returns false for missing file", async () => {
    expect(await fileExists("/nonexistent-file-xyz")).toBe(false);
  });
});
