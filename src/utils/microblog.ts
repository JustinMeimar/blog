import { getCollection, type CollectionEntry } from "astro:content";

export type Microblog = CollectionEntry<"micro-blog">;

export async function getAllMicroblogs(): Promise<Microblog[]> {
  const entries = await getCollection("micro-blog", ({ data }) => {
    return import.meta.env.PROD ? !data.draft : true;
  });

  return entries.sort(
    (a, b) => b.data.publishDate.valueOf() - a.data.publishDate.valueOf()
  );
}

export async function getMicroblogsByTag(tag: string): Promise<Microblog[]> {
  const entries = await getAllMicroblogs();
  return entries.filter((post) => post.data.tags.includes(tag.toLowerCase()));
}

export async function getAllTags(): Promise<Map<string, number>> {
  const entries = await getAllMicroblogs();
  const tags = new Map<string, number>();
  entries.forEach((entry) => {
    entry.data.tags.forEach((tag) => {
      tags.set(tag, (tags.get(tag) ?? 0) + 1);
    });
  });

  return tags;
}

export function formatDate(date: Date): string {
  return date.toLocaleDateString("en-GB", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).replace(/\//g, ".");
}
