# GitHub Maintenance Activity Tool

This repository contains a small GitHub Actions tool that records verifiable repository-maintenance runs three times daily. Each run appends a UTC/IST timestamp, workflow run ID, commit, and repository reference to `maintenance/activity-log.md`.

The workflow is intentionally safer than a timestamp-only README updater:

- It uses GitHub Actions' built-in token and never stores a personal access token.
- It never force-pushes or rewrites history.
- It runs on the default branch only.
- It checks for changes before committing.
- It can be started manually with `workflow_dispatch`.
- It records an auditable maintenance event instead of changing the README on every run.

## Schedule

The default schedule is **08:30, 14:30, and 20:30 Asia/Kolkata time**. GitHub cron expressions use UTC, so the workflow uses `30 3,9,15 * * *`.

To change the schedule, edit `.github/workflows/three-times-daily-maintenance.yml` and convert the desired local times to UTC.

## GitHub setup

After the repository is created, open **Settings → Actions → General → Workflow permissions** and select **Read and write permissions**. The workflow needs write permission to append the maintenance event and push it to the default branch.

You can test it from **Actions → Three Times Daily Maintenance → Run workflow**. A successful run creates one new maintenance record and one commit when the log changes.

## Important limitation

This tool documents actual automation runs and repository maintenance. It does not create empty commits or pretend that coding work happened. A contribution square may appear when the log is updated, but the commits remain transparent and auditable.
