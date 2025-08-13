# jtt.nvim

A simple Neovim plugin to convert JSON to TypeScript interfaces.

## Features

- Converts JSON in current buffer to TypeScript interfaces
- Handles nested objects, arrays and creates separate interfaces
- Automatically copies result to system clipboard
- Sorts properties alphabetically for consistency

## Installation

### Using lazy.nvim

```lua
  {
    "I2olanD/jtt.nvim",
    lazy = false,
    config = function()
      require('jtt').setup()
    end,
    keys = {
      { "<leader>jtt", "<cmd>JsonToTypeScript<cr>", desc = "Copy json to TS" }
    }
  }
```

## Usage

1. Open a JSON file in Neovim
2. Run `:JsonToTypeScript`
3. The TypeScript interfaces will be copied to your clipboard

## Example

Input JSON:

```json
{
  "user": {
    "id": 1,
    "name": "John"
  },
  "posts": [
    {
      "title": "Hello",
      "content": "World"
    }
  ]
}
```

Output TypeScript:

```typescript
interface Posts {
  content: string;
  title: string;
}

interface User {
  id: number;
  name: string;
}

interface Root {
  posts: Posts[];
  user: User;
}
```
