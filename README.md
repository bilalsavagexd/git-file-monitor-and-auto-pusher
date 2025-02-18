# Git File Monitoring and Auto-Push Script

This bash script monitors specified files or directories for changes, automatically commits and pushes those changes to GitHub, and sends email notifications to collaborators using the SendGrid API.

## Prerequisites

Before using this script, ensure you have the following installed and configured:

1. Git (with a properly configured repository)
2. Bash shell
3. curl
4. A SendGrid account with an API key

## Setup Instructions

1. Clone or download the script files to your local machine:
   - `monitor_and_push.sh` - The main script
   - `config.cfg` - Configuration file template

2. Make the script executable:
   ```bash
   chmod +x monitor_and_push.sh
   ```

3. Edit the configuration file (`config.cfg`) to match your environment:
   - `REPO_PATH`: The absolute or relative path to your Git repository
   - `MONITOR_PATH`: The path to the file or directory you want to monitor (absolute or relative to REPO_PATH)
   - `GIT_REMOTE`: The name of the Git remote (e.g., "origin")
   - `GIT_BRANCH`: The branch to push changes to (e.g., "main" or "master")
   - `CHECK_INTERVAL`: Time in seconds between checks (default: 60)
   - `SENDGRID_API_KEY`: Your SendGrid API key
   - `SENDER_EMAIL`: The email address that will appear as the sender
   - `COLLABORATOR_EMAILS`: Comma-separated list of email addresses to notify

## Usage

Run the script by providing the path to your configuration file:

```bash
./monitor_and_push.sh config.cfg
```

For continuous monitoring, you may want to run the script in the background or as a service:

```bash
nohup ./monitor_and_push.sh config.cfg > monitor.log 2>&1 &
```

## How It Works

1. **Initialization**:
   - The script loads the configuration file
   - Validates required parameters
   - Calculates an initial checksum for the monitored path
   
2. **Monitoring Loop**:
   - Recalculates the checksum at regular intervals
   - When a change is detected (checksum differs):
     - Stages the modified files
     - Commits the changes with an auto-generated message
     - Pushes the changes to the remote repository
     - Sends email notifications to all collaborators

3. **Error Handling**:
   - Logs errors for failed Git operations
   - Handles SendGrid API errors
   - Validates configuration parameters

## Troubleshooting

If you encounter issues with the script:

1. Check the log output for error messages
2. Verify that Git is properly configured for your repository
3. Ensure the SendGrid API key has the necessary permissions
4. Make sure all paths in the configuration file are correct

## Extending the Script

You can extend the script functionality by:

1. Adding more detailed logging
2. Implementing different change detection methods
3. Configuring webhooks for additional notifications
4. Implementing file/directory exclusion patterns

## Security Considerations

- Store your SendGrid API key securely
- Don't commit the configuration file with sensitive information to your repository
- Consider using environment variables for sensitive information

## Team Members
- Muhammad Bilal
- Syed Ahmed Haseeb
- Muhammad Bilal Aslam

