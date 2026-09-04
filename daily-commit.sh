#!/bin/bash
set -euo pipefail

REPO_DIR="/home/l1qu3d/github-activity-maintainer"
cd "$REPO_DIR"

git config user.name "L1QU3D"
git config user.email "elduceentertainments@gmail.com"

# Number of commits to generate (default: 5)
COUNT=${1:-5}

mkdir -p maintenance

if [ ! -f maintenance/activity-log.md ]; then
  printf "# Automated Activity Log\n\nThis file tracks daily maintenance runs.\n\n| UTC | Local | Run # |\n|---|---|---|\n" > maintenance/activity-log.md
fi

for i in $(seq 1 "$COUNT"); do
  git pull --rebase origin main || true
  
  timestamp_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  timestamp_local="$(TZ='Asia/Dubai' date '+%Y-%m-%d %H:%M:%S GST')"
  
  printf '| %s | %s | commit_%d |\n' "$timestamp_utc" "$timestamp_local" "$i" >> maintenance/activity-log.md
  
  git add maintenance/activity-log.md
  git commit -m "chore(activity): contribution record $i of $COUNT [$(date '+%Y-%m-%d %H:%M')]"
  git push origin main
  
  # Brief delay between commits
  sleep 1
done

echo "Successfully executed $COUNT contributions!"
