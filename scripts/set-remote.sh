#!/usr/bin/env bash
# Applies scripts/remote.config to this repository's git remotes.
# Run from anywhere:  bash scripts/set-remote.sh
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$script_dir")"
config="$script_dir/remote.config"

if [ ! -f "$config" ]; then
  echo "Config not found: $config" >&2
  exit 1
fi

# Read KEY=value lines, ignoring blanks and comments.
ALT_REMOTE_NAME=github-com
while IFS='=' read -r key value; do
  key="${key%"${key##*[![:space:]]}"}"
  key="${key#"${key%%[![:space:]]*}"}"
  case "$key" in ''|\#*) continue ;; esac
  value="${value%"${value##*[![:space:]]}"}"
  value="${value#"${value%%[![:space:]]*}"}"
  case "$key" in
    GITHUB_HOST|GITHUB_USER|GITHUB_REPO|ALT_REMOTE_NAME|ALT_GITHUB_HOST|ALT_GITHUB_USER|ALT_GITHUB_REPO)
      printf -v "$key" '%s' "$value" ;;
  esac
done < "$config"

set_remote() {
  local name="$1" git_host="$2" user="$3" repo="$4"

  if [ -z "$git_host" ]; then
    # Host blank means "don't want this remote" - remove it if present.
    if git -C "$repo_root" remote | grep -qx "$name"; then
      git -C "$repo_root" remote remove "$name"
      echo "removed  $name"
    fi
    return
  fi

  if [ -z "$user" ] || [ -z "$repo" ]; then
    echo "Skipping '$name': user or repo is empty."
    return
  fi

  local url="https://$git_host/$user/$repo.git"
  if git -C "$repo_root" remote | grep -qx "$name"; then
    git -C "$repo_root" remote set-url "$name" "$url"
    echo "updated  $name -> $url"
  else
    git -C "$repo_root" remote add "$name" "$url"
    echo "added    $name -> $url"
  fi
}

set_remote origin "${GITHUB_HOST:-}" "${GITHUB_USER:-}" "${GITHUB_REPO:-}"
set_remote "${ALT_REMOTE_NAME:-github-com}" "${ALT_GITHUB_HOST:-}" "${ALT_GITHUB_USER:-}" "${ALT_GITHUB_REPO:-}"

echo
echo "Remotes now configured:"
git -C "$repo_root" remote -v
