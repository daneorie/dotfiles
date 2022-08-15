local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
local workspace_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

-- Determine OS
local home = os.getenv "HOME"
if vim.fn.has "mac" == 1 then
	--WORKSPACE_PATH = home .. "/workspace/"
	CONFIG = "mac"
elseif vim.fn.has "unix" == 1 then
	--WORKSPACE_PATH = home .. "/workspace/"
	CONFIG = "linux"
else
	print "Unsupported system"
end

local bundles = {
	vim.fn.glob(home .. "/Documents/GitHub/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar")
}
vim.list_extend(bundles, vim.split(vim.fn.glob(home .. "/Documents/GitHub/vscode-java-test/server/*.jar"), "\n"))

local status, jdtls = pcall(require, "jdtls")
if not status then
	return
end

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local config = {
	-- The command that starts the language server
	-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
		"-Xms1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens", "java.base/java.util=ALL-UNNAMED",
		"--add-opens", "java.base/java.lang=ALL-UNNAMED",
		"-jar", vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
		"-configuration", home .. "/.local/share/nvim/mason/packages/jdtls/config_" .. CONFIG,
		"-data", vim.fn.expand("~/.cache/jdtls-workspace") .. workspace_dir
	},

	root_dir = require("jdtls.setup").find_root({".git", "mvnw", "gradlew", "pom.xml"}),

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	-- for a list of options
	settings = {
		java = {
			configuration = {
				runtimes = {
					{
						name = "JavaSE-1.8",
						path = vim.fn.resolve("/Library/Java/JavaVirtualMachines/openjdk-8.jdk/"),
					},
					{
						name = "JavaSE-11",
						path = vim.fn.resolve("/Library/Java/JavaVirtualMachines/openjdk-11.jdk/"),
					},
					{
						name = "JavaSE-17",
						path = vim.fn.resolve("/Library/Java/JavaVirtualMachines/openjdk-17.jdk/"),
					},
				},
				updateBuildConfiguration = "interactive",
			},
			import = {
				gradle = {
					enabled = true;
				},
				maven = {
					enabled = true;
				},
				exclusions = {
					"**/node_modules/**",
					"**/.metadata/**",
					"**/archetype-resources/**",
					"**/META-INF/maven/**",
					"/**/test/**",
				}
			},
			eclipse = {
				downloadSources = true,
			},
			maven = {
				downloadSources = true,
				updateSnapshots = true,
			},
			implementationsCodeLens = {
				enabled = true,
			},
			referencesCodeLens = {
				enabled = true,
			},
			references = {
				includeDecompiledSources = true,
			},
			inlayHints = {
				parameterNames = {
					enabled = "all",
				},
			},
			format = {
				enabled = false,
			},
			signatureHelp = {
				enabled = true,
			},
			completion = {
				enabled = true,
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.Assert.*",
					"org.junit.Assume.*",
					"org.junit.jupiter.api.Assertions.*",
					"org.junit.jupiter.api.Assumptions.*",
					"org.junit.jupiter.api.DynamicContainer.*",
					"org.junit.jupiter.api.DynamicTest.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*",
				},
			},
			extendedClientCapabilities = extendedClientCapabilities,
		},
	},

	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files
	-- if you want to use additional eclipse.jdt.ls plugins.
	--
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	--
	-- If you don"t plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
	init_options = {
		bundles = bundles
	},

	capabilities = capabilities,
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach(config)

vim.cmd([[ command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>) ]])
vim.cmd([[ command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_set_runtime JdtSetRuntime lua require('jdtls').set_runtime(<f-args>) ]])
vim.cmd([[ command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config() ]])
vim.cmd([[ command! -buffer JdtJol lua require('jdtls').jol() ]])
vim.cmd([[ command! -buffer JdtBytecode lua require('jdtls').javap() ]])
vim.cmd([[ command! -buffer JdtJshell lua require('jdtls').jshell() ]])
--jdtls.add_commands()

local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend('force', options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end
local function silent_map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend('force', options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end
silent_map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
silent_map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
silent_map("n", "M", "<cmd>lua vim.lsp.buf.hover()<CR>")
silent_map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
silent_map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
silent_map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
silent_map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
silent_map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
silent_map("n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>")
silent_map("n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>')
silent_map("n", "gl", '<cmd>lua vim.diagnostic.open_float({ border = "rounded" })<CR>')
silent_map("n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>')
silent_map("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>")
vim.cmd([[ command! Format execute 'lua vim.lsp.buf.formatting{async=true}' ]])
map("n", "<leader>fo",  "<cmd>Format<CR>")

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local vopts = {
  mode = "v", -- VISUAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
  L = {
    name = "Java",
    o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
    v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
    c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
    t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
    T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
    u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
  },
}

local vmappings = {
  L = {
    name = "Java",
    v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
    c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
    m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
  },
}

which_key.register(mappings, opts)
which_key.register(vmappings, vopts)
