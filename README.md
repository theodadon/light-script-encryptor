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

## Modes
- **encrypt** : Encrypt files and directories.
- **decrypt**: Decrypt encrypted files and directories.
- **send**: Send encrypted files via SSH or FTP.

## Options
- **-s <source_directory>**: Specify the source directory or file for encryption. If not provided, it defaults to $HOME/Documents.
- **-d <destination_directory>**: Specify the destination directory where encrypted files will be stored or decrypted files will be restored. Defaults to $HOME/Backups/Documents for encryption                                     and $HOME/Restored for decryption.
- **-c <cipher>**: Choose the encryption algorithm. Default is aes-256-cbc. Supported ciphers include:
                                                                                                      aes-256-cbc
                                                                                                      aes-256-gcm
                                                                                                      aes-128-cbc
- **-m <mode>**: Specify the transfer mode (ssh or ftp) when sending files.
- **-f <file>**: The file to send via SSH or FTP.

## Usage

```bash
./backrypt.sh [mode] [options]
```

## Examples

```bash
./backrypt.sh encrypt -s /path/to/file_or_directory -d /path/to/destination
./backrypt.sh decrypt -d /path/to/restored /path/to/encrypted_file.enc
./backrypt.sh send -m ssh -f /path/to/encrypted_file.enc
./backrypt.sh send -m ftp -f /path/to/encrypted_file.enc
```

## Notes

- The script will prompt you to set an encryption password during the first run. The password will be securely saved in $HOME/.backup_pass.
- Encrypted files are saved with the .enc extension, while encrypted directories are compressed as .tar.enc.
- When restoring encrypted directories, the script will extract the archive in the designated restore folder.

## Licences

- This script is free to use and modify.
