 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#24283b',
    base01 = '#1f2335',
    base02 = '#272c42',
    base03 = '#66709b',
    base04 = '#787c99',
    base05 = '#c0caf5',
    base06 = '#c0caf5',
    base07 = '#c0caf5',
    base08 = '#f7768e',
    base09 = '#73daca',
    base0A = '#bb9af7',
    base0B = '#7aa2f7',
    base0C = '#96e9dc',
    base0D = '#87abf8',
    base0E = '#af89f6',
    base0F = '#cfb8f9',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#c0caf5',          bg = '#24283b' })
  hi('TelescopeBorder',         { fg = '#66709b',             bg = '#24283b' })
  hi('TelescopePromptNormal',   { fg = '#c0caf5',          bg = '#24283b' })
  hi('TelescopePromptBorder',   { fg = '#66709b',             bg = '#24283b' })
  hi('TelescopePromptPrefix',   { fg = '#7aa2f7',             bg = '#24283b' })
  hi('TelescopePromptCounter',  { fg = '#787c99',  bg = '#24283b' })
  hi('TelescopePromptTitle',    { fg = '#24283b',             bg = '#7aa2f7' })
  hi('TelescopePreviewTitle',   { fg = '#24283b',             bg = '#bb9af7' })
  hi('TelescopeResultsTitle',   { fg = '#24283b',             bg = '#73daca' })
  hi('TelescopeSelection',      { fg = '#c0caf5',          bg = '#272c42' })
  hi('TelescopeSelectionCaret', { fg = '#7aa2f7',             bg = '#272c42' })
  hi('TelescopeMatching',       { fg = '#7aa2f7',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#c0caf5',          bg = '#24283b' })
  hi('MiniPickBorder',         { fg = '#66709b',             bg = '#24283b' })
  hi('MiniPickPrompt',   { fg = '#c0caf5',          bg = '#24283b' })
  hi('MiniPickPromptPrefix',   { fg = '#7aa2f7',             bg = '#24283b' })
  hi('MiniPickBorderText',    { fg = '#24283b',             bg = '#7aa2f7' })
  hi('MiniPickMatchCurrent',      { fg = '#c0caf5',          bg = '#272c42' })
  hi('MiniPickPromptCaret', { fg = '#7aa2f7',             bg = '#272c42' })
  hi('MiniPickMatchRanges',       { fg = '#7aa2f7',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
