#!/bin/sh
set -eu

CONFIG_DIR="/app/config"
CONFIG_FILE="$CONFIG_DIR/config.json"
APP_BIN="/app/kiro-rs"

fetch_github_config() {
  : "${GITHUB_TOKEN:?GITHUB_TOKEN is required when GitHub config sync is enabled}"
  : "${GITHUB_REPO:?GITHUB_REPO is required when GitHub config sync is enabled}"
  : "${GITHUB_CONFIG_PATH:?GITHUB_CONFIG_PATH is required when GitHub config sync is enabled}"

  api_url="https://api.github.com/repos/${GITHUB_REPO}/contents/${GITHUB_CONFIG_PATH}"
  if [ "${GITHUB_REF:-}" != "" ]; then
    api_url="${api_url}?ref=${GITHUB_REF}"
  fi

  mkdir -p "$CONFIG_DIR"

  echo "Fetching config.json from GitHub repository ${GITHUB_REPO}"
  curl -fsSL \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.raw" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$api_url" \
    -o "$CONFIG_FILE"
}

if [ "${GITHUB_CONFIG_SYNC:-}" = "1" ] || [ "${GITHUB_CONFIG_SYNC:-}" = "true" ]; then
  fetch_github_config
fi

exec "$APP_BIN" -c "$CONFIG_FILE" --credentials "$CONFIG_DIR/credentials.json"
