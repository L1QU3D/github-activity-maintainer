#!/bin/bash
set -euo pipefail

REPO_DIR="/home/l1qu3d/github-activity-maintainer"
REPO="L1QU3D/github-activity-maintainer"
cd "$REPO_DIR"

git config user.name "L1QU3D"
git config user.email "elduceentertainments@gmail.com"

COMMIT_COUNT=${1:-5}
DO_PR=${2:-true}
DO_ISSUE=${3:-true}

echo "=== 1. COMMITS ACTIVITY ($COMMIT_COUNT commits) ==="
mkdir -p maintenance

if [ ! -f maintenance/activity-log.md ]; then
  printf "# Automated Activity Log\n\nThis file tracks daily maintenance runs.\n\n| UTC | Local | Run # |\n|---|---|---|\n" > maintenance/activity-log.md
fi

for i in $(seq 1 "$COMMIT_COUNT"); do
  git checkout main >/dev/null 2>&1 || true
  git pull --rebase origin main || true
  
  timestamp_utc="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  timestamp_local="$(TZ='Asia/Dubai' date '+%Y-%m-%d %H:%M:%S GST')"
  
  printf '| %s | %s | commit_%d |\n' "$timestamp_utc" "$timestamp_local" "$i" >> maintenance/activity-log.md
  
  git add maintenance/activity-log.md
  git commit -m "chore(activity): contribution record $i of $COMMIT_COUNT [$(date '+%Y-%m-%d %H:%M')]"
  git push origin main
  sleep 1
done

if [ "$DO_ISSUE" = "true" ]; then
  echo "=== 2. ISSUE ACTIVITY (Create + Comment + Close) ==="
  ISSUE_TITLE="Maintenance audit check [$(date '+%Y-%m-%d %H:%M')]"
  ISSUE_BODY="Automated daily health verification for repository maintenance and activity logging."
  
  ISSUE_URL=$(gh issue create --repo "$REPO" --title "$ISSUE_TITLE" --body "$ISSUE_BODY")
  ISSUE_NUM=$(basename "$ISSUE_URL")
  
  # Add issue comment
  gh issue comment "$ISSUE_NUM" --repo "$REPO" --body "Audit checks verified successfully at $(date -u '+%Y-%m-%d %H:%M:%S UTC')."
  
  # Close issue
  gh issue close "$ISSUE_NUM" --repo "$REPO" --reason "completed"
  echo "Created, commented on, and resolved Issue #$ISSUE_NUM"
fi

if [ "$DO_PR" = "true" ]; then
  echo "=== 3. PULL REQUEST & CODE REVIEW ACTIVITY ==="
  BRANCH="patch-$(date +%s)"
  git checkout -b "$BRANCH"
  
  echo "<!-- patch $(date '+%Y-%m-%d %H:%M:%S') -->" >> maintenance/activity-log.md
  git add maintenance/activity-log.md
  git commit -m "feat(routine): maintenance patch for daily review"
  git push origin "$BRANCH"
  
  # Create PR
  PR_URL=$(gh pr create --repo "$REPO" --head "$BRANCH" --base main --title "Routine Daily Maintenance [$(date '+%Y-%m-%d')]" --body "Automated daily maintenance pull request with review activity.")
  PR_NUM=$(basename "$PR_URL")
  
  # Perform Code Review comment/approval on PR
  gh pr review "$PR_NUM" --repo "$REPO" --comment -b "LGTM! Automated review verified code changes."
  
  # Merge PR
  gh pr merge "$PR_NUM" --repo "$REPO" --merge --delete-branch
  
  git checkout main
  git pull --rebase origin main
  echo "Created, reviewed, and merged PR #$PR_NUM"
fi

echo "All activities (Commits, Issues, Pull Requests, Code Reviews) completed successfully!"
