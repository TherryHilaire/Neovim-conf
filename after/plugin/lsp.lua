-- Import necessary modules
local lsp = require('lsp-zero')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

-- Initialize mason
mason.setup()

-- List of servers to ensure are installed
local servers = {
    'ts_ls',
    'eslint',
    'lua_ls',  -- Updated from 'sumneko_lua'
    'rust_analyzer',
    'svelte'
}

-- Ensure the specified servers are installed
mason_lspconfig.setup({
    ensure_installed = servers,
    automatic_installation = true,  -- Automatically install servers not yet installed
})

-- Set up lsp-zero with the installed servers
mason_lspconfig.setup_handlers({
    function(server_name)
        lsp.setup_servers(server_name)
    end
})

-- Configure diagnostic signs
local signs = { Error = '✘', Warn = '▲', Hint = '⚑', Info = '' }
for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Configure preferences and keybindings
lsp.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    if client.name == "eslint" then
        vim.cmd.LspStop('eslint')
        return
    end

    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '<leader>vws', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
    buf_set_keymap('n', '<leader>vd', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<leader>vca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', '<leader>vrr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<leader>vrn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('i', '<C-h>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
end)

-- Finalize the LSP setup
lsp.setup()

-- Configure nvim-cmp for autocompletion
local cmp = require('cmp')
cmp.setup({
    mapping = {
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
    }
})

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = true,
})

-- Symbols-outline configuration
require("symbols-outline").setup({
    highlight_hovered_item = true,
    show_guides = true,
    tools = {
        runnables = {
            use_telescope = true,
        },
        inlay_hints = {
            auto = true,
            show_parameter_hints = false,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },
})
