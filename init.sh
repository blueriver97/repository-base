#!/usr/bin/env bash

# prettier, opencommit 설치
if ! command -v prettier &>/dev/null; then
	npm install -g prettier
	echo "Prettier installed."
else
	echo "Prettier is already installed."
fi

if ! command -v opencommit &>/dev/null; then
	npm install -g opencommit
	echo "Opencommit installed."
else
	echo "Opencommit is already installed."
fi

# install opencommit hook
hooks_path=$(git config core.hooksPath)
if [ "$hooks_path" != ".githooks" ]; then
	oco hook set
	git config core.hooksPath .githooks
fi

# configure opencommit
if [ -z "$GEMINI_API_KEY" ]; then
	# GEMINI_API_KEY 환경변수 확인
	echo "Error: GEMINI_API_KEY environment variable is not set."
	exit 1
elif [ "$(NODE_OPTIONS="--no-deprecation" oco config get OCO_API_KEY | grep '=' | cut -d'=' -f2)" = "undefined" ]; then
	oco config set OCO_API_KEY="$GEMINI_API_KEY"
	oco config set OCO_AI_PROVIDER=gemini OCO_MODEL=gemini-2.0-flash OCO_LANGUAGE=ko OCO_GITPUSH=false OCO_TOKENS_MAX_OUTPUT=512 OCO_ONE_LINE_COMMIT=true
else
	echo "Opencommit already set."
fi

# configure git
git config user.name "blueriver97"
git config user.email "rladudwo0908@naver.com"
git config core.editor "vim"
git config core.quotepath false
git config fetch.prune true
git config merge.ff false
git config alias.recommit "commit --amend"
