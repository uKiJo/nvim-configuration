-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
  return
end

-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
  return
end

-- import typescript plugin safely
local typescript_setup, typescript = pcall(require, "typescript")
if not typescript_setup then
  return
end

local keymap = vim.keymap -- for conciseness

-- enable keybinds only for when lsp server available
local on_attach = function(client, bufnr)
  -- keybind options
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- set keybinds
  keymap.set("n", "gf", "<cmd>Lspsaga lsp_finder<CR>", opts) -- show definition, references
  keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- got to declaration
  keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- see definition and make edits in window
  keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- go to implementation
  keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions
  keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- smart rename
  keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show  diagnostics for line
  keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
  keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
  keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
  keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- show documentation for what is under cursor
  keymap.set("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", opts) -- see outline on right hand side

  -- typescript specific keymaps (e.g. rename file and update imports)
  if client.name == "tsserver" then
    keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>") -- rename file and update imports
    keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>") -- organize imports (not in youtube nvim video)
    keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>") -- remove unused variables (not in youtube nvim video)
  end
end

-- used to enable autocompletion (assign to every lsp server config)
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- configure html server
lspconfig["html"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- configure typescript server with plugin
typescript.setup({
  server = {
    capabilities = capabilities,
    on_attach = on_attach,
  },
})

-- configure css server
lspconfig["cssls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- configure tailwindcss server
lspconfig["tailwindcss"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- configure emmet language server
lspconfig["emmet_ls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
})

-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = { -- custom settings for lua
    Lua = {
      -- make the language server recognize "vim" global
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        -- make language server aware of runtime files
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
    },
  },
})

require("lspconfig").ocamllsp.setup({
  cmd = { "ocamllsp" },
  filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
})

require("lspconfig").rust_analyzer.setup({
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = false,
      },
    },
  },
  capabilities = {
    experimental = {
      serverStatusNotification = true,
    },
    general = {
      positionEncodings = { "utf-16" },
    },
    textDocument = {
      callHierarchy = {
        dynamicRegistration = false,
      },
      codeAction = {
        codeActionLiteralSupport = {
          codeActionKind = {
            valueSet = {
              "",
              "quickfix",
              "refactor",
              "refactor.extract",
              "refactor.inline",
              "refactor.rewrite",
              "source",
              "source.organizeImports",
            },
          },
        },
        dataSupport = true,
        dynamicRegistration = true,
        isPreferredSupport = true,
        resolveSupport = {
          properties = { "edit" },
        },
      },
      completion = {
        completionItem = {
          commitCharactersSupport = false,
          deprecatedSupport = false,
          documentationFormat = { "markdown", "plaintext" },
          preselectSupport = false,
          snippetSupport = false,
        },
        completionItemKind = {
          valueSet = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 },
        },
        contextSupport = false,
        dynamicRegistration = false,
      },
      declaration = {
        linkSupport = true,
      },
      definition = {
        dynamicRegistration = true,
        linkSupport = true,
      },
      diagnostic = {
        dynamicRegistration = false,
      },
      documentHighlight = {
        dynamicRegistration = false,
      },
      documentSymbol = {
        dynamicRegistration = false,
        hierarchicalDocumentSymbolSupport = true,
        symbolKind = {
          valueSet = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 },
        },
      },
      formatting = {
        dynamicRegistration = true,
      },
      hover = {
        contentFormat = { "markdown", "plaintext" },
        dynamicRegistration = true,
      },
      implementation = {
        linkSupport = true,
      },
      inlayHint = {
        dynamicRegistration = true,
        resolveSupport = {
          properties = {},
        },
      },
      publishDiagnostics = {
        dataSupport = true,
        relatedInformation = true,
        tagSupport = {
          valueSet = { 1, 2 },
        },
      },
      rangeFormatting = {
        dynamicRegistration = true,
      },
      references = {
        dynamicRegistration = false,
      },
      rename = {
        dynamicRegistration = true,
        prepareSupport = true,
      },
      semanticTokens = {
        augmentsSyntaxTokens = true,
        dynamicRegistration = false,
        formats = { "relative" },
        multilineTokenSupport = false,
        overlappingTokenSupport = true,
        requests = {
          full = {
            delta = true,
          },
          range = false,
        },
        serverCancelSupport = false,
        tokenModifiers = {
          "declaration",
          "definition",
          "readonly",
          "static",
          "deprecated",
          "abstract",
          "async",
          "modification",
          "documentation",
          "defaultLibrary",
        },
        tokenTypes = {
          "namespace",
          "type",
          "class",
          "enum",
          "interface",
          "struct",
          "typeParameter",
          "parameter",
          "variable",
          "property",
          "enumMember",
          "event",
          "function",
          "method",
          "macro",
          "keyword",
          "modifier",
          "comment",
          "string",
          "number",
          "regexp",
          "operator",
          "decorator",
        },
      },
      signatureHelp = {
        dynamicRegistration = false,
        signatureInformation = {
          activeParameterSupport = true,
          documentationFormat = { "markdown", "plaintext" },
          parameterInformation = {
            labelOffsetSupport = true,
          },
        },
      },
      synchronization = {
        didSave = true,
        dynamicRegistration = false,
        willSave = true,
        willSaveWaitUntil = true,
      },
      typeDefinition = {
        linkSupport = true,
      },
    },
    window = {
      showDocument = {
        support = true,
      },
      showMessage = {
        messageActionItem = {
          additionalPropertiesSupport = false,
        },
      },
      workDoneProgress = true,
    },
    workspace = {
      applyEdit = true,
      configuration = true,
      didChangeWatchedFiles = {
        dynamicRegistration = true,
        relativePatternSupport = true,
      },
      inlayHint = {
        refreshSupport = true,
      },
      semanticTokens = {
        refreshSupport = true,
      },
      symbol = {
        dynamicRegistration = false,
        symbolKind = {
          valueSet = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 },
        },
      },
      workspaceEdit = {
        resourceOperations = { "rename", "create", "delete" },
      },
      workspaceFolders = true,
    },
  },
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
})

require("lspconfig").ocamlls.setup({
  cmd = { "ocaml-language-server", "--stdio" },
  filetypes = { "ocaml", "reason" },
})
