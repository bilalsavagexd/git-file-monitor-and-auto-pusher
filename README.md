# Git File Monitor and Auto-pusher

A bash script that monitors specified files or directories for changes and automatically commits and pushes them to a Git repository. It also provides email notifications to collaborators when changes are detected.

## Features

- Real-time file/directory monitoring
- Automatic git commit and push on changes
- Email notifications via SendGrid
- Error handling and logging
- Support for multiple collaborators
- Configurable monitoring intervals

## Prerequisites

- Git installed and configured
- Bash shell environment
- SendGrid account (for email notifications)
- curl installed (for API requests)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/bilalsavagexd/git-file-monitor-and-auto-pusher.git
cd git-file-monitor-and-auto-pusher
```

2. Make the script executable:
```bash
chmod +x monitor_and_push.sh
```

3. Copy the sample configuration file:
```bash
cp config.cfg.example config.cfg
```

## Configuration

Edit `config.cfg` with your specific settings:

```bash
# Path to the local repository
REPO_PATH="/path/to/your/repository"

# File or directory to monitor
MONITOR_PATH="/path/to/monitor"

# Git remote and branch name
GIT_REMOTE="origin"
GIT_BRANCH="main"

# List of collaborators' email addresses
COLLABORATOR_EMAILS=("user1@example.com" "user2@example.com")

# SendGrid API credentials
SENDGRID_API_KEY="your_sendgrid_api_key"
SENDER_EMAIL="your_sender@email.com"
```

### Important Notes:
- Use forward slashes (/) in paths, even on Windows
- Ensure all paths are absolute
- Make sure the SendGrid API key has "Mail Send" permissions
- Keep your API keys secure and never commit them to the repository

## Usage

1. Start the monitoring script:
```bash
./monitor_and_push.sh
```

2. The script will:
   - Calculate initial checksums of monitored files
   - Watch for changes every 60 seconds
   - Automatically commit and push changes when detected
   - Send email notifications to listed collaborators

To stop monitoring, press `Ctrl+C`.

## Error Handling

The script includes error handling for common scenarios:
- Invalid paths
- Git repository issues
- Network connectivity problems
- Email sending failures

Errors are logged to the console and attempted to be sent via email to collaborators.

## Security Considerations

1. API Keys:
   - Store SendGrid API key securely
   - Consider using environment variables instead of config file
   - Never commit API keys to the repository

2. File Permissions:
   - Ensure script has appropriate execute permissions
   - Protect config.cfg file with restricted read permissions

## Troubleshooting

1. Path Issues:
   - Ensure all paths use forward slashes (/)
   - Use absolute paths
   - Verify directory permissions

2. Git Issues:
   - Ensure repository is properly initialized
   - Verify remote repository access
   - Check git credentials are configured

3. Email Notification Issues:
   - Verify SendGrid API key is valid
   - Check email addresses are correctly formatted
   - Ensure internet connectivity

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## Contact

For support or queries, please contact:
- Muhammad Bilal - muhammadbilalsvg@gmail.com
- Syed Ahmed Haseeb - ahmed13731@gmail.com
- Bilal Aslam - bilal.aslam.338658@gmail.com
