#!/bin/bash

# Load configuration
source config.cfg

# Function to calculate SHA-256 checksum of a file or directory
calculate_checksum() {
    if [[ -f "$MONITOR_PATH" ]]; then
        sha256sum "$MONITOR_PATH" | awk '{print $1}'
    elif [[ -d "$MONITOR_PATH" ]]; then
        find "$MONITOR_PATH" -type f -exec sha256sum {} + | sort | sha256sum | awk '{print $1}'
    else
        echo "Error: $MONITOR_PATH is not a valid file or directory."
        exit 1
    fi
}

# Function to send email notification using SendGrid API
send_email() {
    local subject="Repository Update Notification"
    local message="Changes have been detected and pushed to the repository: $REPO_PATH."

    local email_json=""
    for email in "${COLLABORATOR_EMAILS[@]}"; do
        email_json+="{\"email\": \"$email\"},"
    done
    email_json="${email_json%,}"  # Remove trailing comma

    curl --request POST \
         --url https://api.sendgrid.com/v3/mail/send \
         --header "Authorization: Bearer $SENDGRID_API_KEY" \
         --header "Content-Type: application/json" \
         --data '{
             "personalizations": [{"to": ['"$email_json"']}],
             "from": {"email": "'"$SENDER_EMAIL"'"},
             "subject": "'"$subject"'",
             "content": [{"type": "text/plain", "value": "'"$message"'"}]
         }'
}


# Function to handle errors
handle_error() {
    echo "Error: $1"
    send_email "Error Notification: $1" "An error occurred while processing changes: $1"
    exit 1
}

# Main script logic
cd "$REPO_PATH" || handle_error "Failed to navigate to repository path: $REPO_PATH"

# Calculate initial checksum
initial_checksum=$(calculate_checksum)

# Monitor for changes
while true; do
    current_checksum=$(calculate_checksum)

    if [[ "$current_checksum" != "$initial_checksum" ]]; then
        echo "Change detected in $MONITOR_PATH."

        # Stage, commit, and push changes
        git add "$MONITOR_PATH" || handle_error "Failed to stage changes."
        git commit -m "Auto-commit: Changes detected in $MONITOR_PATH" || handle_error "Failed to commit changes."
        git push "$GIT_REMOTE" "$GIT_BRANCH" || handle_error "Failed to push changes."

        # Send email notification
        send_email || handle_error "Failed to send email notification."

        # Update checksum
        initial_checksum="$current_checksum"
    fi

    # Wait before checking again
    sleep 60
done