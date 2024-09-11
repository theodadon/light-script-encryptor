# Backup, Encrypt & Decrypt Script

This Bash script allows you to:
- **Encrypt** files and directories with different encryption algorithms.
- **Decrypt** files and directories.
- **Send** encrypted files via **SSH** or **FTP**.
- Use **custom source and destination directories**, or fallback to defaults if none are provided.

## Features
- Flexible encryption: Choose between different encryption algorithms (e.g., AES-256-CBC, AES-256-GCM).
- Ability to encrypt both files and directories.
- Customizable source and destination directories for encryption and decryption.
- Send encrypted files over SSH or FTP with user prompts for credentials.
- Automated cleanup: Deletes backups older than 30 days in the destination folder.
  
## Requirements
- **OpenSSL** must be installed for encryption and decryption.
- **curl** must be installed for FTP transfers.
- **ssh** must be installed for SSH transfers.

## Usage

```bash
./backup_encrypt_decrypt.sh [mode] [options]
