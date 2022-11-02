.PHONY: test
DEPS_CLONE_DIR:=deps/pack/vendor/start

deps:
	@mkdir -p ${DEPS_CLONE_DIR}
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ${DEPS_CLONE_DIR}/plenary.nvim
	git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter ${DEPS_CLONE_DIR}/nvim-treesitter

test: deps
	@nvim \
		--headless \
		--noplugin \
		-u tests/install.vim \
		-c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/preload.vim' }"

BENCH_SAMPLE := bench_sample.lua
$(BENCH_SAMPLE):
	curl -o $(BENCH_SAMPLE) https://raw.githubusercontent.com/neovim/neovim/master/runtime/lua/vim/lsp.lua

bench: $(BENCH_SAMPLE)
	@nvim \
		--headless \
		--noplugin \
		-u benchmark/preload.vim \
		-c "lua require('benchmark.compare').run()"
