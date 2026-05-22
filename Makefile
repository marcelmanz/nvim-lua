LUA_FILES := $(shell find . -name "*.lua" -not -path "*/data/*" -not -path "*/.git/*")
MD_FILES  := $(shell find . -name "*.md" -not -path "*/data/*" -not -path "*/.git/*")

.PHONY: fmt fmt-lua fmt-md lint lint-lua check

fmt: fmt-lua fmt-md

fmt-lua:
	stylua $(LUA_FILES)

fmt-md:
	dprint fmt $(MD_FILES)

lint: lint-lua

lint-lua:
	stylua --check $(LUA_FILES)

check: lint
