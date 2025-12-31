# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

jtt.nvim is a Neovim plugin that converts JSON to TypeScript interfaces. It reads JSON from the current buffer, generates TypeScript interface definitions (handling nested objects and arrays), and copies the result to the system clipboard.

## Commands

```bash
# Run tests
lua test/converter_spec.lua

# Lint
luacheck lua/

# Format
stylua lua/
```

## Architecture

```
lua/jtt/
├── init.lua       # Plugin entry point, setup(), Neovim command registration
├── converter.lua  # Core conversion logic: JSON parsing → TypeScript generation
├── json.lua       # Fallback JSON parser (used when vim.json unavailable)
└── converter_spec.lua  # (appears unused, tests live in test/)

test/
└── converter_spec.lua  # Test suite with custom assertion helpers
```

### Core Flow

1. `init.lua` registers `:JsonToTypeScript` command via `setup()`
2. Command reads buffer, validates filetype, calls `converter.json_to_typescript()`
3. `converter.lua` uses `vim.json.decode` (or fallback `json.lua`) to parse JSON
4. `collect_interfaces()` recursively walks the JSON tree, building a map of interface names → object structures
5. Interfaces are sorted alphabetically, with `Root` always last
6. Result is copied to system clipboard (`+` register)

### Key Design Decisions

- Properties within interfaces are sorted alphabetically for deterministic output
- Array types use the property name (capitalized) as the interface name (e.g., `users: []` → `Users[]`)
- Nested objects each become their own interface
- Empty arrays become `any[]`
