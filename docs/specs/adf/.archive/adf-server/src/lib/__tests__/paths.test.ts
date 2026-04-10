import { describe, it, expect } from "vitest";
import os from "node:os";
import path from "node:path";
import { normalizePath, validatePathWithinBase, ADF_ROOT } from "../paths.js";

describe("normalizePath", () => {
  it("expands tilde to homedir", () => {
    const result = normalizePath("~/foo/bar");
    expect(result).toBe(path.join(os.homedir(), "foo", "bar"));
  });

  it("resolves relative paths", () => {
    const result = normalizePath("foo/bar");
    expect(path.isAbsolute(result)).toBe(true);
  });

  it("returns absolute paths as-is", () => {
    const result = normalizePath("/tmp/test");
    expect(result).toBe("/tmp/test");
  });
});

describe("validatePathWithinBase", () => {
  it("accepts paths within base", async () => {
    const result = await validatePathWithinBase(
      path.join(ADF_ROOT, "kb/README.md"),
      ADF_ROOT
    );
    expect(result.valid).toBe(true);
  });

  it("rejects paths escaping base with ..", async () => {
    const result = await validatePathWithinBase(
      path.join(ADF_ROOT, "../../../etc/passwd"),
      ADF_ROOT
    );
    expect(result.valid).toBe(false);
  });

  it("rejects absolute paths outside base", async () => {
    const result = await validatePathWithinBase("/etc/passwd", ADF_ROOT);
    expect(result.valid).toBe(false);
  });

  it("handles non-existent paths gracefully", async () => {
    const result = await validatePathWithinBase(
      path.join(ADF_ROOT, "nonexistent-file.md"),
      ADF_ROOT
    );
    expect(result.valid).toBe(true);
  });

  it("rejects prefix attacks (e.g., /base/foo2 vs /base/foo)", async () => {
    const base = "/tmp/testbase";
    const result = await validatePathWithinBase("/tmp/testbase2/file", base);
    expect(result.valid).toBe(false);
  });
});
