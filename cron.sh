#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Error: Please provide a phone number as an argument."
    echo "Usage: $0 <phone_number>"
    echo "Example: $0 1231231234"
    exit 1
fi

recipient=$1

if ! [[ $recipient =~ ^[0-9]{10}$ ]]; then
    echo "Error: Invalid phone number format. Please use a 10-digit number without any separators."
    echo "Example: 1231231234"
    exit 1
fi

cat << EOF > /tmp/send_message.sh
#!/bin/bash
recipient="$recipient"
message=\$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 80 | paste -sd' ' -)
/usr/bin/osascript << APPLESCRIPT
tell application "Messages"
    set targetService to 1st service whose service type = iMessage
    set targetBuddy to buddy "\$recipient" of targetService
    send "\$message" to targetBuddy
end tell
APPLESCRIPT
EOF

chmod +x /tmp/send_message.sh

# Cron job to run script every minute
(crontab -l 2>/dev/null; echo "* * * * * /tmp/send_message.sh") | crontab -
