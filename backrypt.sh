#!/bin/bash

# Default variables
DEFAULT_SOURCE_DIR="$HOME/Documents"
DEFAULT_DEST_DIR="$HOME/Backups/Documents"
DEFAULT_DECRYPT_DIR="$HOME/Restored"
PASSWORD_FILE="$HOME/.backup_pass"
DEFAULT_CIPHER="aes-256-cbc"

# Dynamic variables set via options
SOURCE_DIR=""
DEST_DIR=""
DECRYPT_DIR=""
CIPHER="$DEFAULT_CIPHER"
FTP_SERVER=""
FTP_USER=""
FTP_PASSWORD=""
SSH_SERVER=""
SSH_USER=""

# Function to display help
usage() {
    echo "Usage: $0 [-s source_directory] [-d destination_directory] [-c cipher] [-m mode] [-f file]"
    echo "Modes:"
    echo "  encrypt   : Encrypt files/directories"
    echo "  decrypt   : Decrypt files/directories"
    echo "  send      : Send a file via SSH or FTP"
    echo "Options:"
    echo "  -s        : Source directory to encrypt (default: $DEFAULT_SOURCE_DIR)"
    echo "  -d        : Destination directory (default: $DEFAULT_DEST_DIR for encryption, $DEFAULT_DECRYPT_DIR for decryption)"
    echo "  -c        : Encryption algorithm (default: $DEFAULT_CIPHER)"
    echo "  -m        : Transfer mode (ssh or ftp)"
    echo "  -f        : File to send via transfer"
    exit 1
}

# Create directories if needed
create_directories() {
    mkdir -p "$DEST_DIR"
    mkdir -p "$DECRYPT_DIR"
}

# Function to encrypt a file or directory
encrypt() {
    local item="$1"
    if [[ -f "$item" ]]; then
        # If it's a file, encrypt it
        openssl enc -$CIPHER -salt -pbkdf2 -in "$item" -out "$DEST_DIR/$(basename "$item").enc" -pass file:"$PASSWORD_FILE"
        echo "The file $(basename "$item") has been encrypted."
    elif [[ -d "$item" ]]; then
        # If it's a directory, create a tar archive and then encrypt it
        tar -cf "$DEST_DIR/$(basename "$item").tar" -C "$(dirname "$item")" "$(basename "$item")"
        openssl enc -$CIPHER -salt -pbkdf2 -in "$DEST_DIR/$(basename "$item").tar" -out "$DEST_DIR/$(basename "$item").tar.enc" -pass file:"$PASSWORD_FILE"
        rm "$DEST_DIR/$(basename "$item").tar"
        echo "The directory $(basename "$item") has been encrypted."
    fi
}

# Function to decrypt a file or directory
decrypt() {
    local item="$1"
    if [[ -f "$item" && "$item" == *.enc ]]; then
        openssl enc -d -$CIPHER -pbkdf2 -in "$item" -out "$DECRYPT_DIR/$(basename "${item%.enc}")" -pass file:"$PASSWORD_FILE"
        echo "The file $(basename "$item") has been decrypted to $DECRYPT_DIR."
    elif [[ -f "$item" && "$item" == *.tar.enc ]]; then
        openssl enc -d -$CIPHER -pbkdf2 -in "$item" -out "$DECRYPT_DIR/$(basename "${item%.enc}")" -pass file:"$PASSWORD_FILE"
        tar -xf "$DECRYPT_DIR/$(basename "${item%.enc}")" -C "$DECRYPT_DIR"
        rm "$DECRYPT_DIR/$(basename "${item%.enc}")"
        echo "The directory $(basename "$item") has been decrypted to $DECRYPT_DIR."
    else
        echo "The specified file is not valid or does not appear to be encrypted."
    fi
}

# Function to send files via SSH
send_via_ssh() {
    local item="$1"
    if [[ -z "$SSH_SERVER" ]]; then
        read -p "Enter the SSH server (e.g., user@host): " SSH_SERVER
    fi
    scp "$item" "$SSH_SERVER:~/"
    echo "The file $item has been sent to $SSH_SERVER via SSH."
}

# Function to send files via FTP
send_via_ftp() {
    local item="$1"
    if [[ -z "$FTP_SERVER" ]]; then
        read -p "Enter the FTP server: " FTP_SERVER
        read -p "Enter the FTP username: " FTP_USER
        read -sp "Enter the FTP password: " FTP_PASSWORD
        echo
    fi
    curl -T "$item" --ftp-create-dirs -u "$FTP_USER:$FTP_PASSWORD" "ftp://$FTP_SERVER/"
    echo "The file $item has been sent to $FTP_SERVER via FTP."
}

# Function to handle file/directory encryption
backup_and_encrypt() {
    # Iterate and encrypt items in the source directory
    for item in "$SOURCE_DIR"/*; do
        encrypt "$item"
    done
    
    # Remove files older than 30 days
    find "$DEST_DIR" -type f -mtime +30 -exec rm {} \;
    echo "Backup and encryption completed."
}

# Check if the password file exists
if [[ ! -f "$PASSWORD_FILE" ]]; then
    read -sp "Enter a password for encryption: " PASSWORD
    echo
    echo -n "$PASSWORD" > "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"
fi

# Parse options
while getopts ":s:d:c:m:f:" opt; do
    case $opt in
        s) SOURCE_DIR="$OPTARG" ;;
        d) DEST_DIR="$OPTARG" ;;
        c) CIPHER="$OPTARG" ;;
        m) MODE="$OPTARG" ;;
        f) FILE_TO_SEND="$OPTARG" ;;
        *) usage ;;
    esac
done

# Set default paths if not specified
if [[ -z "$SOURCE_DIR" ]]; then
    SOURCE_DIR="$DEFAULT_SOURCE_DIR"
fi
if [[ -z "$DEST_DIR" ]]; then
    DEST_DIR="$DEFAULT_DEST_DIR"
fi
if [[ -z "$DECRYPT_DIR" ]]; then
    DECRYPT_DIR="$DEFAULT_DECRYPT_DIR"
fi

create_directories

# Execute commands based on mode
case "$1" in
    encrypt)
        backup_and_encrypt
        ;;
    decrypt)
        if [[ -z "$2" ]]; then
            echo "Please specify a file or directory to decrypt."
        else
            decrypt "$2"
        fi
        ;;
    send)
        if [[ -z "$MODE" || -z "$FILE_TO_SEND" ]]; then
            echo "Usage: $0 send -m {ssh|ftp} -f <file_to_send>"
        elif [[ "$MODE" == "ssh" ]]; then
            send_via_ssh "$FILE_TO_SEND"
        elif [[ "$MODE" == "ftp" ]]; then
            send_via_ftp "$FILE_TO_SEND"
        else
            echo "Invalid transfer option. Use 'ssh' or 'ftp'."
        fi
        ;;
    *)
        usage
        ;;
esac
