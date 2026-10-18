-- ESP32 + PlatformIO, Neovim 0.11+. No plugins required.
vim.g.mapleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.clipboard = 'unnamedplus'

local home = vim.fn.expand('~'):gsub('\\', '/')
local clangd = vim.fn.exepath('clangd')
if clangd == '' then clangd = 'C:/Program Files/LLVM/bin/clangd.exe' end

vim.lsp.config('clangd', {
  cmd = {
    clangd,
    '--background-index',
    '--clang-tidy',
    '--completion-style=detailed',
    '--header-insertion=never',
    -- Allow clangd to query PlatformIO's cross-compilers for system headers.
    '--query-driver=' .. home .. '/.platformio/packages/**/bin/*',
  },
  filetypes = { 'c', 'cpp' },
  root_markers = { 'platformio.ini', 'compile_commands.json', '.git' },
})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  severity_sort = true,
  update_in_insert = false,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
    local function map(key, action)
      vim.keymap.set('n', key, action, { buffer = event.buf })
    end
    map('gd', vim.lsp.buf.definition)
    map('gr', vim.lsp.buf.references)
    map('K', vim.lsp.buf.hover)
    map('<leader>rn', vim.lsp.buf.rename)
    map('<leader>ca', vim.lsp.buf.code_action)
    map('<leader>e', vim.diagnostic.open_float)
    map('<leader>q', vim.diagnostic.setqflist)
    vim.keymap.set('i', '<C-Space>', vim.lsp.completion.get, { buffer = event.buf })
  end,
})
vim.lsp.enable('clangd')

vim.keymap.set('n', '<leader>w', '<cmd>write<CR>')
vim.keymap.set('n', '<leader>f', '<cmd>Explore<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')

local function platformio(args)
  local root = vim.fs.root(0, { 'platformio.ini' }) or vim.fs.root(vim.fn.getcwd(), { 'platformio.ini' })
  if not root then
    vim.notify('Open a file in a PlatformIO project first.', vim.log.levels.ERROR)
    return
  end
  local pio = vim.fn.exepath('pio')
  if pio == '' then pio = home .. '/.platformio/penv/Scripts/pio.exe' end
  if vim.fn.executable(pio) ~= 1 then
    vim.notify('PlatformIO executable not found: ' .. pio, vim.log.levels.ERROR)
    return
  end
  -- Save edited firmware buffers before building or uploading.
  vim.cmd('wall')
  vim.cmd('botright 14new')
  vim.fn.jobstart(vim.list_extend({ pio }, args), { term = true, cwd = root })
  vim.cmd('startinsert')
end

vim.api.nvim_create_user_command('PioBuild', function() platformio({ 'run' }) end, {})
vim.api.nvim_create_user_command('PioUpload', function() platformio({ 'run', '-t', 'upload' }) end, {})
vim.api.nvim_create_user_command('PioMonitor', function() platformio({ 'device', 'monitor' }) end, {})
vim.api.nvim_create_user_command('PioCompdb', function() platformio({ 'run', '-t', 'compiledb' }) end, {})
vim.keymap.set('n', '<leader>pb', '<cmd>PioBuild<CR>')
vim.keymap.set('n', '<leader>pu', '<cmd>PioUpload<CR>')
vim.keymap.set('n', '<leader>pm', '<cmd>PioMonitor<CR>')
