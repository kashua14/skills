---
name: "anthropic-docs"
description: "Use when the user asks how to build with Anthropic products, the Claude API, or Claude Code and needs up-to-date official documentation with citations, help choosing the latest Claude model for a use case, or explicit migration and prompt-upgrade guidance; prioritize Anthropic docs MCP tools or web search on docs.anthropic.com, use bundled references only as helper context."
---

# Anthropic Docs

Provide authoritative, current guidance from Anthropic developer docs using `docs.anthropic.com`. Always prioritize the official Anthropic docs over speculation for Claude-related questions. This skill loads targeted reference files for model-selection and Claude-specific requests, but current Anthropic docs remain authoritative.

## Quick start

- Search `docs.anthropic.com` for the most relevant doc pages using the `WebSearch` tool with `site:docs.anthropic.com`.
- Use `WebFetch` to pull exact sections and quote/paraphrase accurately.
- Load only the relevant file from `references/` when the question is about model selection or a Claude API upgrade.

## Anthropic product snapshots

1. **Claude API (Messages API)**: Stateless, multimodal, tool-using API for building with Claude models.
2. **Claude Code**: Anthropic's CLI and IDE extension for AI-assisted software development.
3. **Claude Code SDK**: Programmatic interface for building agents and automations on top of Claude Code.
4. **MCP (Model Context Protocol)**: Open protocol for connecting Claude to external tools and data sources.
5. **Anthropic SDK**: Official SDKs for Python (`anthropic`) and TypeScript (`@anthropic-ai/sdk`).
6. **Prompt caching**: Reduce costs and latency by caching large context blocks with `cache_control`.
7. **Tool use**: Enable Claude to call external functions and APIs with structured JSON schemas.

## Latest models (as of April 2026)

- **claude-opus-4-6** — Most capable, for complex tasks
- **claude-sonnet-4-6** — Balanced capability and speed (default recommendation)
- **claude-haiku-4-5-20251001** — Fastest, lowest cost

Always verify current model availability at `docs.anthropic.com/en/docs/about-claude/models`.

## Workflow

1. Clarify the product scope: is this a Messages API question, Claude Code question, SDK/tool-use question, or model-selection question?
2. If it is a model-selection request, load `references/latest-model.md` if present, then verify against current docs.
3. Search docs with a precise query using `WebSearch` restricted to `docs.anthropic.com`.
4. Fetch the best page and the exact section needed using `WebFetch`.
5. For API upgrade reviews, make per-usage-site output explicit: target model, parameter changes, prompt adjustments, and compatibility status.
6. Answer with concise guidance and cite the doc source.

## Reference map

Read only what you need:

- `references/latest-model.md` → model-selection and "best/latest/current model" questions; verify every recommendation against current Anthropic docs before answering.

## Quality rules

- Treat Anthropic docs as the source of truth; avoid speculation.
- Keep quotes short and within policy limits; prefer paraphrase with citations.
- If multiple pages differ, call out the difference and cite both.
- If docs do not cover the user's need, say so and offer next steps.

## Tooling notes

- Use `WebSearch` with `site:docs.anthropic.com` for targeted searches.
- Use `WebFetch` to read full doc pages when needed.
- When docs are not found via search, try fetching the canonical doc URL directly.
