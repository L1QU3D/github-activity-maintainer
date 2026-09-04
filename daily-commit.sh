#!/bin/bash
set -euo pipefail

REPO_DIR="/home/l1qu3d/github-activity-maintainer"
cd "$REPO_DIR"

git config user.name "L1QU3D"
git config user.email "elduceentertainments@gmail.com"

git pull --rebase origin main || true

mkdir -p maintenance
timestamp_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
timestamp_local="$(TZ='Asia/Dubai' date '+%Y-%m-%d %H:%M:%S GST')"

if [ ! -f maintenance/activity-log.md ]; then
  printf "# Automated Activity Log\n\nThis file tracks daily maintenance runs.\n\n| UTC | Local | Event |\n|---|---|---|\n" > maintenance/activity-log.md
fi

printf '| %s | %s | scheduled_maintenance |\n' "$timestamp_utc" "$timestamp_local" >> maintenance/activity-log.md

git add maintenance/activity-log.md
git commit -m "chore(activity): record daily contribution [$(date '+%Y-%m-%d')]"
git push origin main
