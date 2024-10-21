# bash-totp

Implementation of TOTP code generator in Bash.

I wrote this script out of pure boredom (I use KeePassXC for managing TOTP), however I think that it may be useful to other people, for example in restricted environments.

## Requirements

`oathtool` and `gnupg`. That's all.

If you prefer OpenSSL for some reason, use code from [`v1.0.0-openssl` tag](https://github.com/SimonSays2310/bash-totp/releases/tag/v1.0.0-openssl).

## Usage

`./totp.sh add` - adds an entry in database folder and encrypts it with a password.

`./totp.sh open` - opens a saved entry.

`./totp.sh delete` - permanently deletes an entry from database folder.
