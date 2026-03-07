# Scan Funnel

Sends scanned image files to a remote file server over SSH using rsync. Set your scanner to save files into `./scans/` and run the script to push them to your remote file server.

Sync is **additive only** — it will never delete or overwrite files on the remote file server.

## Supported file types

`.tif` `.tiff` `.png` `.jpeg` `.jpg` (case-insensitive)

Non-image files in `./scans/` are skipped and logged.

## Setup

1. Clone the repo:
   ```
   git clone git@github.com:neilcronin/scanfunnel.git
   cd scanfunnel
   ```

2. Create your config file:
   ```
   cp config.env.example config.env
   ```

3. Edit `config.env` with your remote server details:
   ```
   RSYNC_USER=youruser
   RSYNC_HOST=yourhost.example.com
   RSYNC_PATH=/path/to/remote/scans
   ```

4. Make sure you have SSH key access to the remote host:
   ```
   ssh youruser@yourhost.example.com echo "connected"
   ```

5. The remote host must have rsync installed and enabled.

## Usage

Put image files in `./scans/`, then run:

```
./sync.sh
```

Logs are written to `./logs/sync.log`.

## License

[Unlicense](LICENSE) — public domain.
