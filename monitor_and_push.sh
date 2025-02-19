#!/bin/bash

# Load configuration
source config.cfg

# Function to calculate SHA-256 checksum of a file or directory
calculate_checksum() {
    if [[ -f "$MONITOR_PATH" ]]; then
        sha256sum "$MONITOR_PATH" | awk '{print $1}'
    elif [[ -d "$MONITOR_PATH" ]]; then
        # Use -print0 and -0 for better handling of filenames with spaces
        find "$MONITOR_PATH" -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | awk '{print $1}'
    else
        echo "Error: $MONITOR_PATH is not a valid file or directory."
        exit 1
    fi
}

# Function to send email notification using SendGrid API
send_email() {
    local subject="Repository Update Notification"
    local message="Changes have been detected and pushed to the repository: $REPO_PATH"
    
    # Build recipients array properly
    local email_json=""
    for email in "${COLLABORATOR_EMAILS[@]}"; do
        [[ -n "$email_json" ]] && email_json+=","
        email_json+="{\"email\": \"$email\"}"
    done

    # Escape special characters in message
    message=$(echo "$message" | sed 's/"/\\"/g')
    
    curl --request POST \
         --url "https://api.sendgrid.com/v3/mail/send" \
         --header "Authorization: Bearer $SENDGRID_API_KEY" \
         --header "Content-Type: application/json" \
         --data "{
             \"personalizations\": [{\"to\": [$email_json]}],
             \"from\": {\"email\": \"$SENDER_EMAIL\"},
             \"subject\": \"$subject\",
             \"content\": [{\"type\": \"text/plain\", \"value\": \"$message\"}]
         }" || return 1
}

# Function to handle errors
handle_error() {
    local error_message="$1"
    echo "Error: $error_message" >&2
    send_email || echo "Failed to send error notification email" >&2
    exit 1
}

# Validate configuration
[[ -z "$REPO_PATH" ]] && handle_error "REPO_PATH is not set"
[[ -z "$MONITOR_PATH" ]] && handle_error "MONITOR_PATH is not set"
[[ -z "$GIT_REMOTE" ]] && handle_error "GIT_REMOTE is not set"
[[ -z "$GIT_BRANCH" ]] && handle_error "GIT_BRANCH is not set"
[[ -z "$SENDGRID_API_KEY" ]] && handle_error "SENDGRID_API_KEY is not set"
[[ -z "$SENDER_EMAIL" ]] && handle_error "SENDER_EMAIL is not set"
[[ ${#COLLABORATOR_EMAILS[@]} -eq 0 ]] && handle_error "No COLLABORATOR_EMAILS specified"

# Ensure we're in a git repository
cd "$REPO_PATH" || handle_error "Failed to navigate to repository path: $REPO_PATH"
git rev-parse --git-dir > /dev/null 2>&1 || handle_error "Not a git repository: $REPO_PATH"

# Calculate initial checksum
initial_checksum=$(calculate_checksum)
[[ -z "$initial_checksum" ]] && handle_error "Failed to calculate initial checksum"

echo "Starting file monitor for: $MONITOR_PATH"
echo "Initial checksum: $initial_checksum"

# Monitor for changes
while true; do
    current_checksum=$(calculate_checksum)
    if [[ "$current_checksum" != "$initial_checksum" ]]; then
        echo "Change detected in $MONITOR_PATH at $(date)"
        
        # Stage, commit, and push changes
        if git add "$MONITOR_PATH" && \
           git commit -m "Auto-commit: Changes detected in $MONITOR_PATH at $(date)" && \
           git push "$GIT_REMOTE" "$GIT_BRANCH"; then
            
            # Send email notification
            if send_email; then
                echo "Changes successfully committed and notification sent"
                initial_checksum="$current_checksum"
            else
                handle_error "Failed to send email notification"
            fi
        else
            handle_error "Failed to commit and push changes"
        fi
    fi
    
    sleep 60
done
