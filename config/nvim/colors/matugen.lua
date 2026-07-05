-- ============================================================
-- matugen.vim — auto-generated Material You colorscheme
-- Colors are sourced from lua/generated/matugen.lua
-- ============================================================

local colors = require("generated.matugen")

local c = colors

vim.g.colors_name = "matugen"

local hl = vim.api.nvim_set_hl or vim.api.nvim_command

local function set_hl(group, opts)
  if vim.api.nvim_set_hl then
    vim.api.nvim_set_hl(0, group, opts)
  else
    local parts = { "highlight", group }
    for k, v in pairs(opts) do
      parts[#parts + 1] = k .. "=" .. tostring(v)
    end
    vim.cmd(table.concat(parts, " "))
  end
end

-- ============================================================
-- Editor / UI
-- ============================================================
set_hl("Normal",       { fg = c.on_surface, bg = c.background })
set_hl("NormalFloat",  { fg = c.on_surface, bg = c.surface_container })
set_hl("FloatBorder",  { fg = c.outline, bg = c.surface_container })
set_hl("EndOfBuffer",  { fg = c.background })
set_hl("Cursor",       { fg = c.background, bg = c.on_surface })
set_hl("CursorLine",   { bg = c.surface_container })
set_hl("CursorLineNr", { fg = c.primary, bg = c.surface_container })
set_hl("LineNr",       { fg = c.outline })
set_hl("SignColumn",   { bg = c.background })
set_hl("ColorColumn",  { bg = c.surface_container })
set_hl("Conceal",      { fg = c.outline })

-- ============================================================
-- Selection / Visual
-- ============================================================
set_hl("Visual",       { bg = c.surface_container })
set_hl("VisualNOS",    { bg = c.surface_container })
set_hl("Search",       { fg = c.background, bg = c.primary })
set_hl("IncSearch",    { fg = c.background, bg = c.tertiary })
set_hl("CurSearch",    { link = "IncSearch" })
set_hl("Substitute",   { fg = c.background, bg = c.error })

-- ============================================================
-- Splits / Separators
-- ============================================================
set_hl("WinSeparator", { fg = c.outline, bg = c.background })
set_hl("VertSplit",    { fg = c.outline })
set_hl("Folded",       { fg = c.on_surface_variant, bg = c.surface_container })
set_hl("FoldColumn",   { fg = c.outline, bg = c.background })

-- ============================================================
-- Pmenu (popup menu)
-- ============================================================
set_hl("Pmenu",       { fg = c.on_surface, bg = c.surface_container })
set_hl("PmenuSel",    { fg = c.background, bg = c.primary })
set_hl("PmenuSbar",   { bg = c.surface_container_high })
set_hl("PmenuThumb",  { bg = c.outline })

-- ============================================================
-- Tabs
-- ============================================================
set_hl("TabLine",      { fg = c.on_surface_variant, bg = c.surface_container })
set_hl("TabLineSel",   { fg = c.primary, bg = c.background })
set_hl("TabLineFill",  { bg = c.background })

-- ============================================================
-- Statusline / Winbar
-- ============================================================
set_hl("StatusLine",   { fg = c.on_surface, bg = c.surface_container })
set_hl("StatusLineNC", { fg = c.on_surface_variant, bg = c.background })
set_hl("WinBar",       { fg = c.on_surface, bg = c.surface_container })
set_hl("WinBarNC",     { fg = c.on_surface_variant, bg = c.background })

-- ============================================================
-- Diagnostics / Errors
-- ============================================================
set_hl("ErrorMsg",     { fg = c.error, bg = c.background })
set_hl("WarningMsg",   { fg = c.primary })
set_hl("ModeMsg",      { fg = c.on_surface })
set_hl("MoreMsg",      { fg = c.tertiary })
set_hl("Question",     { fg = c.primary })
set_hl("Title",        { fg = c.primary, bold = true })

-- ============================================================
-- Spell
-- ============================================================
set_hl("SpellBad",     { sp = c.error, undercurl = true })
set_hl("SpellCap",     { sp = c.primary, undercurl = true })
set_hl("SpellLocal",   { sp = c.tertiary, undercurl = true })
set_hl("SpellRare",    { sp = c.secondary, undercurl = true })

-- ============================================================
-- Diff
-- ============================================================
set_hl("DiffAdd",      { bg = c.surface_container, fg = c.tertiary })
set_hl("DiffChange",   { bg = c.surface_container, fg = c.primary })
set_hl("DiffDelete",   { bg = c.surface_container, fg = c.error })
set_hl("DiffText",     { bg = c.surface_container, fg = c.on_surface })

-- ============================================================
-- Syntax / Code
-- ============================================================
set_hl("Comment",      { fg = c.outline, italic = true })
set_hl("Constant",     { fg = c.primary })
set_hl("String",       { fg = c.tertiary })
set_hl("Number",       { fg = c.secondary })
set_hl("Boolean",      { fg = c.primary })
set_hl("Float",        { fg = c.secondary })
set_hl("Identifier",   { fg = c.on_surface })
set_hl("Function",     { fg = c.primary })
set_hl("Statement",    { fg = c.primary })
set_hl("Conditional",  { fg = c.primary })
set_hl("Repeat",       { fg = c.primary })
set_hl("Label",        { fg = c.secondary })
set_hl("Operator",     { fg = c.on_surface })
set_hl("Keyword",      { fg = c.primary })
set_hl("Exception",    { fg = c.error })
set_hl("PreProc",      { fg = c.secondary })
set_hl("Include",      { fg = c.secondary })
set_hl("Define",       { fg = c.secondary })
set_hl("Macro",        { fg = c.secondary })
set_hl("PreCondit",    { fg = c.secondary })
set_hl("Type",         { fg = c.secondary })
set_hl("StorageClass", { fg = c.secondary })
set_hl("Structure",    { fg = c.secondary })
set_hl("Typedef",      { fg = c.secondary })
set_hl("Special",      { fg = c.primary })
set_hl("Tag",          { fg = c.on_surface })
set_hl("Delimiter",    { fg = c.outline })
set_hl("SpecialChar",  { fg = c.primary })
set_hl("SpecialComment", { fg = c.outline, italic = true })
set_hl("Debug",        { fg = c.error })
set_hl("Underlined",   { fg = c.primary, underline = true })
set_hl("Ignore",       { fg = c.background })
set_hl("Todo",         { fg = c.background, bg = c.primary })
set_hl("Error",        { fg = c.error })
set_hl("Whitespace",   { fg = c.outline })
set_hl("NonText",      { fg = c.outline })
set_hl("SpecialKey",   { fg = c.outline })
set_hl("MatchParen",   { fg = c.background, bg = c.primary, bold = true })

-- ============================================================
-- Telescope
-- ============================================================
set_hl("TelescopeNormal",       { fg = c.on_surface, bg = c.surface_container })
set_hl("TelescopeBorder",       { fg = c.outline, bg = c.surface_container })
set_hl("TelescopeTitle",        { fg = c.primary, bg = c.surface_container })
set_hl("TelescopePromptNormal", { fg = c.on_surface, bg = c.background })
set_hl("TelescopePromptBorder", { fg = c.primary, bg = c.background })
set_hl("TelescopePromptTitle",  { fg = c.background, bg = c.primary })
set_hl("TelescopeSelection",    { bg = c.surface_container_high })
set_hl("TelescopeMultiSelection", { fg = c.primary })
set_hl("TelescopePreviewNormal",{ fg = c.on_surface, bg = c.background })
set_hl("TelescopePreviewBorder",{ fg = c.outline, bg = c.background })
set_hl("TelescopeResultsNormal",{ fg = c.on_surface, bg = c.background })
set_hl("TelescopeResultsBorder",{ fg = c.outline, bg = c.background })

-- ============================================================
-- NvimTree / File Explorer
-- ============================================================
set_hl("NvimTreeNormal",           { fg = c.on_surface, bg = c.background })
set_hl("NvimTreeVertSplit",        { fg = c.outline, bg = c.background })
set_hl("NvimTreeFolderName",       { fg = c.primary })
set_hl("NvimTreeOpenedFolderName", { fg = c.primary, bold = true })
set_hl("NvimTreeEmptyFolderName",  { fg = c.on_surface_variant })
set_hl("NvimTreeFileIcon",         { fg = c.on_surface_variant })
set_hl("NvimTreeExecFile",         { fg = c.tertiary })
set_hl("NvimTreeImageFile",        { fg = c.secondary })
set_hl("NvimTreeSymlink",          { fg = c.primary })
set_hl("NvimTreeGitDirty",         { fg = c.primary })
set_hl("NvimTreeGitStaged",        { fg = c.tertiary })
set_hl("NvimTreeGitMerge",         { fg = c.primary })
set_hl("NvimTreeGitRenamed",       { fg = c.primary })
set_hl("NvimTreeGitNew",           { fg = c.tertiary })
set_hl("NvimTreeGitDeleted",       { fg = c.error })
set_hl("NvimTreeWindowPicker",     { fg = c.primary, bg = c.surface_container })
set_hl("NvimTreeRootFolder",       { fg = c.primary, bold = true })
set_hl("NvimTreeSpecialFile",      { fg = c.primary })

-- ============================================================
-- WhichKey
-- ============================================================
set_hl("WhichKey",          { fg = c.primary, bold = true })
set_hl("WhichKeyGroup",     { fg = c.secondary })
set_hl("WhichKeyDesc",      { fg = c.on_surface })
set_hl("WhichKeySeperator", { fg = c.outline })
set_hl("WhichKeyFloat",     { bg = c.surface_container })

-- ============================================================
-- LSP / Diagnostics
-- ============================================================
set_hl("DiagnosticError",            { fg = c.error })
set_hl("DiagnosticWarn",             { fg = c.primary })
set_hl("DiagnosticInfo",             { fg = c.tertiary })
set_hl("DiagnosticHint",             { fg = c.on_surface_variant })
set_hl("DiagnosticUnderlineError",   { sp = c.error, undercurl = true })
set_hl("DiagnosticUnderlineWarn",    { sp = c.primary, undercurl = true })
set_hl("DiagnosticUnderlineInfo",    { sp = c.tertiary, undercurl = true })
set_hl("DiagnosticUnderlineHint",    { sp = c.on_surface_variant, undercurl = true })
set_hl("LspReferenceText",            { bg = c.surface_container_high })
set_hl("LspReferenceRead",            { bg = c.surface_container_high })
set_hl("LspReferenceWrite",           { bg = c.surface_container_high })
set_hl("LspCodeLens",                 { fg = c.outline })
set_hl("LspSignatureActiveParameter", { fg = c.primary, bold = true })

-- ============================================================
-- Notify
-- ============================================================
set_hl("NoiceCmdlinePopup", { fg = c.on_surface, bg = c.surface_container })
set_hl("NoiceCmdlineIcon",  { fg = c.primary })

-- ============================================================
-- Misc UI
-- ============================================================
set_hl("Bold",       { bold = true })
set_hl("Italic",     { italic = true })
set_hl("Directory",  { fg = c.primary })

-- ============================================================
-- Terminal colors (for :terminal)
-- ============================================================
-- stylua: ignore
local term_colors = {
  c.background,     -- 0  black
  c.error,          -- 1  red
  c.tertiary,       -- 2  green
  c.primary,        -- 3  yellow
  c.secondary,      -- 4  blue
  c.primary,        -- 5  magenta
  c.tertiary,       -- 6  cyan
  c.on_surface,     -- 7  white
  c.outline,        -- 8  bright black
  c.error,          -- 9  bright red
  c.tertiary,       -- 10 bright green
  c.primary,        -- 11 bright yellow
  c.secondary,      -- 12 bright blue
  c.primary,        -- 13 bright magenta
  c.tertiary,       -- 14 bright cyan
  c.on_surface,     -- 15 bright white
}
for i, col in ipairs(term_colors) do
  vim.g["terminal_color_" .. (i - 1)] = col
end
