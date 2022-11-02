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

bench:
	@nvim \
		--headless \
		--noplugin \
		-u benchmark/bench.vim
