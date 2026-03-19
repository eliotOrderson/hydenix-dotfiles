# # 1. Zero API Hallucination & Query Documents & Verification (Strict)
- **Never guess** API signatures. Treat unverified 3rd-party APIs as unknown.
- **Identify Dependencies:** Read config files (`pyproject.toml`, `Cargo.toml`, `package.json`, etc.) via `shell` to get exact versions.
- **Mandatory `ctx7` CLI Check:** For ALL non-standard libraries (existing or new). Include the exact doc snippet in your reasoning *before* coding.
- **Halt Condition:** If `ctx7` CLI yields no docs, STOP and ask the user for a link/confirmation. Do not proceed.
---

# # 2. Project Awareness & Change Control
- **Assess Blast Radius:** Use `gitnexus` CLI to find all call sites before modifying existing interfaces or structures.
- **Minimal Impact:** Make localized, backward-compatible changes. Do not refactor unrelated modules or escalate type strictness unless explicitly requested.
---

# # 3. Execution & Tool Workflow (Enforced Order)
**Strict Workflow (do not deviate or skip any step):**

**Step 1: Analyze (Pre-code)**
1. **Primary: `gitnexus` CLI (Architecture)**: Map codebase & dependencies. Symbol Navigation, definition lookup, Reference Search. Perform **Blast Radius Analysis**.
2. **Fallback L1: `serena` (System Logic)**: Use if cross-repo patterns or design intent are missing.
3. **Fallback L2: `shell` (Low-Level)**: Use `rg`, `grep`, `head` for `.env`, logs, and manifests.
4. **Validation: `ctx7` CLI (External Docs)**: Verify all external APIs. Output: **Exact Version** + **Doc Snippet**.
Note: 
```bash
# ctx7 cli exmaples: 
ctx7 library react "how to use hooks"
ctx7 docs /facebook/react "useEffect examples"
# gitnexus cli examples
  analyze [options] [path]        Index a repository (full analysis)
  list                            List all indexed repositories
  status                          Show index status for current repo
  clean [options]                 Delete GitNexus index for current repo
  wiki [options] [path]           Generate repository wiki from knowledge graph
  augment <pattern>               Augment a search pattern with knowledge graph context (used by hooks)
  query [options] <search_query>  Search the knowledge graph for execution flows related to a concept
  context [options] [name]        360-degree view of a code symbol: callers, callees, processes
  impact [options] <target>       Blast radius analysis: what breaks if you change a symbol
  cypher [options] <query>        Execute raw Cypher query against the knowledge graph
  help [command]                  display help for command
```

**Step 2: Implement**
Write complete, idiomatic code with robust error handling. Priority: 1. Compatibility, 2. Modern Best Practices.

**Step 3: Verify (Post-code)**
Use `shell` to run type checks, linters, and tests. Extract exact logs.

**Step 4: Evidence-Based Debugging (Strict)**
- No guessing. Use `shell` to extract **exact stack traces**.
- Diagnose strictly based on evidence. Fix root causes.
- **Halt Condition:** If architectural impact is unclear, STOP and ask.
---
# # 4. Code & Documents & Communication Style
- **Tone:** Concise, technically precise. Zero filler.
- **Commenting:** Explain *WHY*, never *WHAT*. **Strictly NO line-by-line comments.**
- **Terminology:** Keep industry-standard technical terms (e.g., "Middleware", "Payload", "Deadlock", "Race Condition") in **English** within the Chinese response to ensure zero ambiguity.
---

# # 5. Final Response Structure (Mandatory)
- Call Me Master. Final Output Must include Master.
- Reason step-by-step internally in English.
- Final response **exclusively in Chinese** (except for English technical terms), structured as follows:
  1. **变更总结**：一句话说明修改内容和理由（技术精确，保留核心术语）。
  2. **验证结果**：列出执行的检查命令 + 结果摘要（必须附带关键证据/日志摘录）。
  3. **技术备注**（可选）：说明如何保持了向后兼容性或处理了潜在的下游影响。
  4. 如触发 Halt：明确说明原因并精确提问。

@RTK.md
