#!/bin/bash

# Load configuration file
source config.cfg

# Validate required configuration variables
if [[ -z "$POSTMARK_API_KEY" || -z "$SENDER_EMAIL" || -z "$COLLABORATORS" || -z "$REPO_PATH" || -z "$WATCH_PATH" ]]; then
    echo "Error: Missing required configuration values. Please check config.cfg."
    exit 1
fi

# Store initial checksum of the monitored file/directory
INITIAL_CHECKSUM=$(sha256sum "$WATCH_PATH" | awk '{print $1}')

# Function to send an email notification using Postmark
send_email() {
    curl -X POST "https://api.postmarkapp.com/email" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "X-Postmark-Server-Token: $POSTMARK_API_KEY" \
        -d '{
            "From": "'"$SENDER_EMAIL"'",
            "To": "'"$COLLABORATORS"'",
            "Subject": "Repository Update Notification",
            "TextBody": "Changes have been detected and pushed to the repository."
        }' > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "✅ Email notification sent via Postmark."
    else
        echo "⚠️ Failed to send email notification."
    fi
}

# Function to commit and push changes to GitHub
commit_and_push() {
    cd "$REPO_PATH" || { echo "❌ Error: Failed to access repository path."; exit 1; }

    # Add, commit, and push changes
    git add "$WATCH_PATH"
    git commit -m "Auto-commit: Changes detected in $(basename "$WATCH_PATH")"
    
    if git push "$GIT_REMOTE" "$GIT_BRANCH"; then
        echo "✅ Changes pushed to GitHub."
        send_email
    else
        echo "⚠️ Error: Failed to push changes to GitHub."
    fi
}

# Continuous monitoring loop
while true; do
    CURRENT_CHECKSUM=$(sha256sum "$WATCH_PATH" | awk '{print $1}')
    
    if [ "$INITIAL_CHECKSUM" != "$CURRENT_CHECKSUM" ]; then
        echo "🚀 Change detected in $WATCH_PATH! Committing and pushing..."
        commit_and_push
        INITIAL_CHECKSUM=$CURRENT_CHECKSUM
    fi

    sleep 10  # Check for changes every 10 seconds
done
