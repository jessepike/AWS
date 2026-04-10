import path from "node:path";
import os from "node:os";
import fs from "node:fs";

export function normalizePath(p: string): string {
  if (p.startsWith("~/")) {
    p = path.join(os.homedir(), p.slice(2));
  }
  return path.resolve(p);
}

export const ADF_ROOT = normalizePath(
  process.env.ADF_ROOT || "~/code/_shared/adf"
);

export const REGISTRY_ROOT = normalizePath(
  process.env.ADF_REGISTRY_ROOT || "~/code/_shared/capabilities-registry"
);

/**
 * Validates that a candidate path is within a base directory.
 * Uses path.relative() check — rejects if result starts with ".." or is absolute.
 * For existing paths, also verifies via fs.realpath() to resolve symlinks.
 * Returns { valid: true, resolved } or { valid: false, error }.
 */
export async function validatePathWithinBase(
  candidate: string,
  base: string
): Promise<{ valid: true; resolved: string } | { valid: false; error: string }> {
  const resolved = normalizePath(candidate);
  const rel = path.relative(base, resolved);

  // Reject if relative path escapes base
  if (rel.startsWith("..") || path.isAbsolute(rel)) {
    return { valid: false, error: `Path '${candidate}' is outside allowed directory.` };
  }

  // For existing paths, verify realpath doesn't escape via symlinks
  try {
    const real = await fs.promises.realpath(resolved);
    const realRel = path.relative(base, real);
    if (realRel.startsWith("..") || path.isAbsolute(realRel)) {
      return { valid: false, error: `Path '${candidate}' resolves outside allowed directory via symlink.` };
    }
    return { valid: true, resolved: real };
  } catch {
    // Path doesn't exist — that's fine, we already validated the logical path
    return { valid: true, resolved };
  }
}
