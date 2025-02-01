# Blazingly fast and lightweight fuzzy finder for Neovim

# Installation with `lazy`

```lua
return {
  "askerdev/fzf.nvim",
  keys = function()
    local fzf = require("fzf")
    return {
      { "<leader><leader>", mode = "n", fzf.all_files, desc = "Find all files" },
      { "<leader>fg", mode = "n", fzf.git_files, desc = "Find git files" },
      { "<leader>ff", mode = "n", fzf.files, desc = "Find files" },
    }
  end,
}
```

# Usage

```lua
local fzf = require("fzf")
fzf.all_files() -- calls fzf.git_files() if currently in git repo, otherwise fzf.files() will be called
fzf.git_files()
fzf.files()
```
