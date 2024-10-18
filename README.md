# bash-totp

Implementation of TOTP code generator in Bash.

I wrote this script out of pure boredom (I use KeePassXC for managing TOTP), however I think that it may be useful to other people, for example in restricted environments.

## Requirements

`oathtool` and `openssl` (usually already bundled in lots of Linux distros, try running `openssl` in your terminal). That's all.

If you are using the code from `gpg` branch, then you need `gnupg` instead of `openssl` (obviously).

## Usage

`./totp.sh add` - adds an entry in database folder and encrypts it with a password.

`./totp.sh open` - opens a saved entry.

`./totp.sh delete` - permanently deletes an entry from database folder.
