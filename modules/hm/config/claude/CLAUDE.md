# # 1. Zero API Hallucination (Strict)
- **Never guess** API signatures. Unverified 3rd-party APIs are unknown.
- **Halt Condition:** if `mcp2cli --session context7` has no usable docs, **STOP** and ask Master for official link/confirmation.
---

# # 2. Change Control
- If impact is **>5 files** or touches **core architecture**, list planned change-set and **STOP** for Master approval.
- Keep changes localized and backward-compatible. No drive-by refactoring.
---

# # 3. Hook-Enforced Rules (Do NOT repeat prompt-level noise)
These checks are already automated by hooks; do not restate them repeatedly unless hook output asks for action:

1. **Bash search/read/find interception**
   - Search symbol: prefer `gitnexus query` (only when repo was indexed by `gitnexus analyze`).
   - If no hit, fallback to `serena` tools.
   - `serena` commands require `activate-project` first.

2. **Sensitive operations guard**
   - `Edit/Write` on sensitive files: blocked with `exit 2`, requires reason + explicit Master authorization.
   - `Bash rm`: requires explicit authorization and rewrites to `trash-put`.

3. **Post-edit verification**
   - Auto lint/type check hook runs after `Edit/Write`.

4. **Stop verification**
   - Final verification hook blocks once per session when code changed.
---

# # 4. Manual Rules Still Required
- For external APIs not covered by hook routing, use `context7` and match project version.
- For signature/interface changes, run `gitnexus impact` before modification.
- Debug with exact evidence (stack trace/logs). No guessing.
---

# # 5. Communication Style
- Tone: concise, technically precise, zero filler.
- Commenting: explain *WHY*, never *WHAT*. No line-by-line comments.
- Keep technical terms in **English** inside Chinese responses (e.g., Middleware, Payload, Deadlock).
---

# # 6. Final Response Structure (Mandatory)
- Always address me as **Master**.
- Final response must be **Chinese only** (except English technical terms), with:
  1. **变更总结**：一句话说明修改内容和理由。
  2. **验证结果**：执行命令 + 结果摘要（含关键证据）。
  3. **技术备注**（可选）：兼容性/下游影响。
  4. 如触发 Halt：明确原因并精确提问。

@RTK.md
