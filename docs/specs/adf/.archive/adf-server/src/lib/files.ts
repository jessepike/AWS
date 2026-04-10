import fs from "node:fs";
import matter from "gray-matter";

export async function readFile(filePath: string): Promise<string> {
  return fs.promises.readFile(filePath, "utf-8");
}

export async function readFrontmatter(
  filePath: string
): Promise<{ data: Record<string, unknown>; content: string }> {
  const raw = await readFile(filePath);
  const { data, content } = matter(raw);
  return { data, content };
}

export async function fileExists(filePath: string): Promise<boolean> {
  try {
    await fs.promises.access(filePath, fs.constants.R_OK);
    return true;
  } catch {
    return false;
  }
}
