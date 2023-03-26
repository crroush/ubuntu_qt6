#!/bin/bash
set -e

# Get the UID and GID of the mounted volume
USER_ID=$(stat -c "%u" /data )
GROUP_ID=$(stat -c "%g" /data )

# Check if the group exists, if not, create it
if ! getent group devusr >/dev/null; then
    groupadd -g $GROUP_ID -o devusr
fi

# Check if the user exists, if not, create it and add to sudoers
if ! getent passwd devusr >/dev/null; then
    useradd -m -u $USER_ID -g $GROUP_ID -o -s /bin/bash devusr

    # Allow the new user to run sudo without a password
    echo "devusr ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

# Run the command provided as arguments to the container
exec /usr/bin/sudo -u devusr -- "$@"

