#!/usr/bin/env python3
"""Extract typed prompts and tool-usage stats from Claude Code transcripts."""
import argparse, collections, datetime, glob, json, math, os, re

NOISE = ("<system-reminder", "<local-command", "<command-", "<task-notification", "<bash-",
         "Caveat:", "[Request interrupted", "Another Claude session sent")
PREFIX = re.compile(r"^\s*(?:(?:cd\s+\S+|export\s+\w+=\S+|[A-Z_]+=\S+)\s*(?:;|&&)\s*)+")
EXPORT = re.compile(r"\bexport\s+(\w+=[^\s;&]+)")

def text_of(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return " ".join(b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text")
    return ""

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--days", type=int, default=30)
    ap.add_argument("--project", default="", help="substring filter on project dir name")
    ap.add_argument("--max-chars", type=int, default=400)
    ap.add_argument("--chunk-bytes", type=int, default=130_000)
    ap.add_argument("--max-chunks", type=int, default=6)
    a = ap.parse_args()

    since = (datetime.date.today() - datetime.timedelta(days=a.days)).isoformat()
    root = os.path.expanduser("~/.claude/projects")
    prompts, tools, bash, exports, skills, sessions = [], *(collections.Counter() for _ in range(4)), set()

    for f in glob.glob(f"{root}/*/*.jsonl"):
        proj = os.path.basename(os.path.dirname(f))
        if a.project not in proj:
            continue
        for line in open(f, errors="ignore"):
            try:
                e = json.loads(line)
            except ValueError:
                continue
            day = e.get("timestamp", "")[:10]
            if e.get("isSidechain") or day < since:
                continue
            content = (e.get("message") or {}).get("content")
            if e.get("type") == "user" and not e.get("isMeta"):
                t = text_of(content).strip()
                if m := re.search(r"<command-name>/?([^<\s]+)", t):
                    skills[m.group(1)] += 1
                if t and not t.startswith(NOISE):
                    sessions.add(f)
                    prompts.append((day, proj, " ".join(t.split())[: a.max_chars]))
            elif e.get("type") == "assistant" and isinstance(content, list):
                for b in content:
                    if b.get("type") != "tool_use":
                        continue
                    name, inp = b["name"], b.get("input") or {}
                    tools[name] += 1
                    if name == "Skill":
                        skills[inp.get("skill")] += 1
                    elif name == "Bash":
                        cmd = inp.get("command", "")
                        exports.update(EXPORT.findall(cmd))
                        bash[" ".join(PREFIX.sub("", cmd).split()[:2])] += 1

    prompts.sort()
    os.makedirs(a.out, exist_ok=True)
    with open(f"{a.out}/prompts.tsv", "w") as o:
        o.writelines("\t".join(p) + "\n" for p in prompts)

    repeated = collections.Counter(p[2] for p in prompts if len(p[2]) > 40)
    with open(f"{a.out}/stats.txt", "w") as o:
        def section(title, counter, n):
            o.write(f"## {title}\n" + "".join(f"{c:6d}  {k}\n" for k, c in counter.most_common(n)) + "\n")
        o.write(f"{len(prompts)} prompts, {len(sessions)} sessions, since {since}\n\n")
        section("Projects", collections.Counter(p[1] for p in prompts), 30)
        section("Skills and slash commands", skills, 40)
        section("Tools", tools, 30)
        section("Bash commands (cd/export prefixes stripped)", bash, 60)
        section("Recurring exports (setup Claude keeps redoing)", collections.Counter({k: v for k, v in exports.items() if v > 2}), 20)
        section("Prompts typed more than once", collections.Counter({k: v for k, v in repeated.items() if v > 1}), 20)

    data = open(f"{a.out}/prompts.tsv").read().splitlines(keepends=True)
    total = sum(map(len, data))
    n = max(1, min(a.max_chunks, math.ceil(total / a.chunk_bytes)))
    target, chunks, cur = total / n, [], []
    for line in data:
        cur.append(line)
        if sum(map(len, cur)) >= target and len(chunks) < n - 1:
            chunks.append(cur); cur = []
    chunks.append(cur)
    for i, c in enumerate(chunks):
        with open(f"{a.out}/chunk_{i:02d}.tsv", "w") as o:
            o.writelines(c)
    print(f"{len(prompts)} prompts ({total // 1000} KB) -> {len(chunks)} chunks in {a.out}")

if __name__ == "__main__":
    main()
