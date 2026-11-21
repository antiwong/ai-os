-- Options
vim.g.mapleader = " "
local o = vim.opt
o.termguicolors = true
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"
o.scrolloff = 8
o.mouse = "a"
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.undofile = true
o.updatetime = 250
o.showmode = false
o.fillchars = { eob = " " }
o.winborder = "rounded"

-- Bootstrap lazy.nvim (plugin manager; clones from GitHub on first launch)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "catppuccin/nvim", name = "catppuccin", priority = 1000,
    opts = { flavour = "latte", transparent_background = true,
      integrations = { gitsigns = true, telescope = true, which_key = true,
        indent_blankline = { enabled = true }, neotree = true } },
    config = function(_, opts)
      -- ai-os-theme writes flavour + palette overrides here
      local ok, t = pcall(dofile, vim.fn.expand("~/.config/ai-os/theme/nvim.lua"))
      if ok and type(t) == "table" then opts = vim.tbl_deep_extend("force", opts, t) end
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "nvim-lualine/lualine.nvim", opts = { options = { theme = "catppuccin",
      globalstatus = true, section_separators = "", component_separators = "|" } } },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  { "lewis6991/gitsigns.nvim", opts = {} },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    } },
  { "nvim-neo-tree/neo-tree.nvim", branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    keys = { { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File tree" } } },
}, { ui = { border = "rounded" }, checker = { enabled = false } })
