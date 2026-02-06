import { getCollection, type CollectionEntry } from "astro:content";

export type TIL = CollectionEntry<"til">;

export async function getAllTILs(): Promise<TIL[]> {
  const tils = await getCollection("til", ({ data }) => {
    return import.meta.env.PROD ? !data.draft : true;
  });

  return tils.sort(
    (a, b) => b.data.publishDate.valueOf() - a.data.publishDate.valueOf()
  );
}

export async function getTILsByTag(tag: string): Promise<TIL[]> {
  const tils = await getAllTILs();
  return tils.filter((post) => post.data.tags.includes(tag.toLowerCase()));
}

export async function getAllTags(): Promise<Map<string, number>> {
  const tils = await getAllTILs();
  const tags = new Map<string, number>();
  tils.forEach((til) => {
    til.data.tags.forEach((tag) => {
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
