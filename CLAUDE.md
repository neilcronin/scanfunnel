# Project: Scan Funnel

## What it does
Notices when new image files appear in `./scans/` and copies them to a remote file server via rsync/ssh. Run manually for now.

## Sync rules
- Only additive to the remote file server. Never delete or modify anything on the remote.
- If a file exists on the remote but not locally, do nothing.
- If a file exists in both places, do nothing.
- If a file exists locally but not on the remote, copy it to the remote.

## File types
Supported image extensions: `.tif`, `.tiff`, `.png`, `.jpeg`, `.jpg`.
Files that don't match a known image pattern should be logged (not synced).

## Project layout
- `./scans/` — where scanned images land (gitignored)
- `./logs/` — log file output (gitignored)
- `config.env` — rsync target URL and username (gitignored)
- `sync.sh` — the rsync sync script (run manually)

## Tech stack
rsync, ssh, shell script, macOS.

## Future: automatic file watching
LaunchAgent with `WatchPaths` will likely be used to automatically trigger sync when new files appear in `./scans/`. For now, sync is run manually.

## Current status
Starting from scratch.
