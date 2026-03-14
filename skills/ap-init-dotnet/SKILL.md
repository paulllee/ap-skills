---
name: ap-init-dotnet
description: "Add .NET build tooling standards to AGENTS.md — dotnet CLI, formatting, test commands. Use after /ap-init on .NET projects."
disable-model-invocation: true
allowed-tools: Read Edit Glob
---

# AP-Init-Dotnet

Inject .NET build tooling standards into the project's `AGENTS.md`.

## Steps

1. Read `AGENTS.md`. If it doesn't exist, tell the user to run `/ap-init` first.

2. Find the `## Build Tools` section. If it doesn't exist, create it after `## Tech Stack`.

3. Append under `## Build Tools` (or replace the HTML comment placeholder):

```
### .NET (dotnet CLI)
- Build: `dotnet build`
- Run: `dotnet run`
- Tests: `dotnet test`
- Formatting: `dotnet format`
- Add package: `dotnet add package <name>`
- Analyzers: treat warnings as errors in CI
```

4. Print what was added. Plain text.

## Examples

- `/ap-init-dotnet`
