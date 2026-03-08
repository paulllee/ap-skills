---
name: ap-docs
description: "Look up documentation for any library or tool. Uses Context7 MCP if available, falls back to WebFetch/curl."
argument-hint: "<query> [library-name]"
allowed-tools: mcp__plugin_context7_context7__resolve-library-id mcp__plugin_context7_context7__query-docs WebFetch Bash
---

# AP-Docs

Look up documentation for the query in `$ARGUMENTS`. Parse out the library name (last arg if provided, otherwise infer from query).

## Lookup Strategy

1. **Try Context7 MCP first:** Call `resolve-library-id` → `query-docs`. If either fails or is unavailable, fall to step 2.
2. **Fallback:** Use `WebFetch` against the library's official docs URL. If WebFetch is unavailable, use `curl -sL` via Bash.

Never fabricate versions, API signatures, or behavior. Say so if authoritative docs cannot be found.

## Output

```
**Source:** <URL or "Context7 MCP">
**Library:** <name> <version if known>

<relevant excerpt>

**Example:**
<code example if available>
```

Keep it concise — no padding, no restating the question.
