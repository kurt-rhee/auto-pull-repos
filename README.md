# Git Repository Pull Script Configuration Guide

This directory contains an automated script that pulls specific branches from multiple git repositories on a scheduled basis.

## Files

- `pull_all_repos.sh` - Main script that pulls configured repositories
- `crontab_config.txt` - Cron job configuration examples
- `README.md` - This configuration guide

## Quick Setup

1. **Configure repositories and branches** by editing the `REPO_CONFIG` array in `pull_all_repos.sh`
2. **Set the base directory** where your repositories are located
3. **Install the cron job** to run twice daily at 12:00 (noon and midnight)
4. **Test the script** manually before relying on automation

## Configuration

### Repository Configuration

Edit the `REPO_CONFIG` associative array in `pull_all_repos.sh`:

```bash
declare -A REPO_CONFIG=(
    ["api"]="dev"
    ["web-app"]="dev"
    ["core"]="main"
    ["pv-expected-energy"]="main"
    ["docs-mdbook"]="main"
)
```

**Format:** `["repository-folder-name"]="branch-name"`

### Base Directory

Update the `BASE_DIR` variable to point to where your repositories are located:

```bash
BASE_DIR="$HOME/Projects"  # Change this to your repositories directory
```

### Logging

Logs are saved to `$HOME/logs/git_pull.log` by default. To change:

```bash
LOG_FILE="/path/to/your/preferred/log/location.log"
```

## Installation

### 1. Make Script Executable

```bash
chmod +x Programs/_cron/pull_all_repos.sh
```

### 2. Test the Script

Run manually to ensure it works:

```bash
./Programs/_cron/pull_all_repos.sh
```

### 3. Install Cron Job

Add to your crontab to run twice daily at 12:00 (noon and midnight):

```bash
crontab -e
```

Add this line (adjust path as needed):

```
0 0,12 * * * /full/path/to/Programs/_cron/pull_all_repos.sh
```

## Usage Examples

### Adding a New Repository

To add a new repository called `my-project` that should pull from the `develop` branch:

1. Add to the configuration:
   ```bash
   declare -A REPO_CONFIG=(
       ["api"]="dev"
       ["web-app"]="dev"
       ["core"]="main"
       ["pv-expected-energy"]="main"
       ["docs-mdbook"]="main"
       ["my-project"]="develop"  # New entry
   )
   ```

2. Ensure the repository exists at `$BASE_DIR/my-project`

### Changing Branch for Existing Repository

To change the `api` repository from `dev` to `main`:

```bash
declare -A REPO_CONFIG=(
    ["api"]="main"          # Changed from "dev"
    ["web-app"]="dev"
    ["core"]="main"
    ["pv-expected-energy"]="main"
    ["docs-mdbook"]="main"
)
```

### Removing a Repository

Simply delete the line from the `REPO_CONFIG` array.

## Troubleshooting

### Check Logs

View recent activity:

```bash
tail -f ~/logs/git_pull.log
```

### Common Issues

1. **Permission denied**: Ensure the script is executable
2. **Repository not found**: Check that `BASE_DIR` points to the correct location
3. **Branch doesn't exist**: Verify branch names are correct
4. **Git authentication**: Ensure your git credentials are configured for automated access

### Manual Testing

Test a single repository pull:

```bash
cd /path/to/your/repository
git fetch origin
git checkout branch-name
git pull origin branch-name
```

### Cron Job Verification

Check if cron job is installed:

```bash
crontab -l
```

Check cron service is running:

```bash
# On macOS
sudo launchctl list | grep cron

# On Linux
systemctl status cron
```

## Current Configuration

The script is currently configured to pull:

- `api` → `dev` branch
- `web-app` → `dev` branch  
- `core` → `main` branch
- `pv-expected-energy` → `main` branch
- `docs-mdbook` → `main` branch

Schedule: Twice daily at 12:00 AM and 12:00 PM

## Security Notes

- The script assumes SSH keys or credential helpers are configured for git authentication
- Log files may contain repository paths - ensure appropriate file permissions
- Consider using a dedicated user account for automated git operations in production environments

## Customization

### Different Schedule

To change the schedule, modify the cron expression:

- Once daily at 6 AM: `0 6 * * *`
- Every 4 hours: `0 */4 * * *`
- Weekdays only at noon: `0 12 * * 1-5`

### Email Notifications

Add email notification on failure by modifying the cron job:

```
0 0,12 * * * /path/to/script || echo "Git pull failed" | mail -s "Git Pull Failure" your@email.com
```

### Different Base Directories

If repositories are in different locations, you can modify the script to use a more complex configuration:

```bash
declare -A REPO_PATHS=(
    ["api"]="/path/to/api"
    ["web-app"]="/different/path/to/web-app"
)
```
