rockspec_format = "3.0"
package = "rustaceanvim"
version = "dev-1"

description = {
	summary = "🦀 Supercharge your Rust experience in Neovim! A heavily modified fork of rust-tools.nvim",
	license = "GPL-2.0-only",
	maintainer = "mrcjkb",
	labels = {
		"dap",
		"debug-adapter-protocol",
		"language-server-protocol",
		"lsp",
		"neovim",
		"nvim",
		"plugin",
		"rust",
		"rust-analyzer",
		"rust-lang",
		"rust-tools",
	},
}

dependencies = {
	"lua==5.1",
}

source = {
	url = "git+https://github.com/mrcjkb/rustaceanvim.git",
}

test = {
	type = "busted-nlua",
}

build = {
	type = "builtin",
}
