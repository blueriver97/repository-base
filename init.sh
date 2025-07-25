#!/usr/bin/env bash

NODE_VERSION="22"

echo "[*] OS 확인 중..."
OS=$(uname -s)

# ----------------------------------------
# Node.js / npm 설치
# ----------------------------------------
install_node() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    echo "[*] Node.js 및 npm이 이미 설치되어 있습니다."
    return
  fi

  if [ "$OS" = "Darwin" ]; then
    echo "[*] macOS 환경 감지됨"

    if ! command -v brew &>/dev/null; then
      echo "[*] Homebrew 설치 중..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "[*] Node.js 설치 중..."
    brew install node@${NODE_VERSION}

    echo "[*] PATH 설정 반영 중..."
    echo 'export PATH="/opt/homebrew/opt/node@'"${NODE_VERSION}"'/bin:$PATH"' >> ~/.zprofile
    export PATH="/opt/homebrew/opt/node@${NODE_VERSION}/bin:$PATH"

    brew link --force --overwrite node@${NODE_VERSION}

  elif [ "$OS" = "Linux" ]; then
    echo "[*] Ubuntu 환경 감지됨"

    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
    sudo apt-get update
    sudo apt-get install -y nodejs
  else
    echo "지원되지 않는 OS입니다: $OS"
    exit 1
  fi

  echo "[+] Node 설치 완료: $(node -v)"
  echo "[+] NPM 설치 완료: $(npm -v)"
}

# ----------------------------------------
# 글로벌 npm 패키지 설치
# ----------------------------------------
install_global_packages() {
  if ! command -v prettier &>/dev/null; then
    npm install -g prettier
    echo "[+] Prettier 설치 완료"
  else
    echo "[*] Prettier 이미 설치됨"
  fi

  if ! command -v opencommit &>/dev/null; then
    npm install -g opencommit
    echo "[+] Opencommit 설치 완료"
  else
    echo "[*] Opencommit 이미 설치됨"
  fi
}

# ----------------------------------------
# Opencommit Git Hook 및 설정
# ----------------------------------------
setup_opencommit() {
  # Git hook path 설정
  hooks_path=$(git config core.hooksPath)
  if [ "$hooks_path" != ".githooks" ]; then
    echo "[*] Git hooks 경로를 .githooks로 설정 중..."
    oco hook set
    git config core.hooksPath .githooks
  else
    echo "[*] Git hooks 경로 이미 설정됨"
  fi

  # GEMINI_API_KEY 확인
  if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY 환경변수가 설정되어 있지 않습니다."
    exit 1
  fi

  current_key=$(NODE_OPTIONS="--no-deprecation" oco config get OCO_API_KEY | grep '=' | cut -d'=' -f2)

  if [ "$current_key" = "undefined" ] || [ -z "$current_key" ]; then
    echo "[*] Opencommit 설정 중..."
    oco config set OCO_API_KEY="$GEMINI_API_KEY"
    oco config set OCO_AI_PROVIDER=gemini
    oco config set OCO_MODEL=gemini-2.0-flash
    oco config set OCO_LANGUAGE=ko
    oco config set OCO_GITPUSH=false
    oco config set OCO_TOKENS_MAX_OUTPUT=512
    oco config set OCO_TOKENS_MAX_INPUT=40960
    oco config set OCO_ONE_LINE_COMMIT=true
  else
    echo "[*] Opencommit 설정 이미 완료됨"
  fi
}

# ----------------------------------------
# Git 설정
# ----------------------------------------
setup_git_config() {
  echo "[*] Git 설정 중..."
  git config user.name "blueriver97"
  git config user.email "rladudwo0908@naver.com"
  git config core.editor "vim"
  git config core.quotepath false
  git config fetch.prune true
  git config merge.ff false
  git config alias.recommit "commit --amend"
}

# ----------------------------------------
# 실행
# ----------------------------------------
pip install -U pip setuptools wheel pre-commit
install_node
install_global_packages
setup_opencommit
setup_git_config

echo "✅ 모든 설치 및 설정이 완료되었습니다."
