#!/bin/bash
keys_dir="$1"

for k in $keys_dir/*.pub
do
    user=$(basename "$k" .pub)
    ssh_dir="/home/$user/.ssh"
    auth_keys_file="$ssh_dir/authorized_keys"

    echo "Creating user $user"

    adduser --ingroup scm "$user" --disabled-password
    passwd -u "$user"
    mkdir "$ssh_dir"
    mv "$k" "$auth_keys_file"

    chown -R "$user:scm" "$ssh_dir"
    chmod 700 "$ssh_dir"
    chmod 600 "$auth_keys_file"
done
