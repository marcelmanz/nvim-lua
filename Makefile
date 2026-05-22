LUA_FILES := $(shell find . -name "*.lua" -not -path "*/data/*" -not -path "*/.git/*" -not -name "nil.lua")
MD_FILES  := $(shell find . -name "*.md" -not -path "*/data/*" -not -path "*/.git/*")

.PHONY: format format-lua format-md lint lint-lua check

format: format-lua format-md

format-lua:
	stylua $(LUA_FILES)

format-md:
	dprint fmt $(MD_FILES)

lint: lint-lua

lint-lua:
	stylua --check $(LUA_FILES)
	emmylua_check .

check: format lint
