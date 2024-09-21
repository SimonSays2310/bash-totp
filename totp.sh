#!/usr/bin/env bash
# shellcheck disable=2164
DATABASE="./database"

if [ -z "$1" ]; then
	echo "Usage: ./totp.sh add"
	echo "       ./totp.sh open"
	exit 1
fi

if [[ $1 == "add" ]]; then
	read -r -p "What's the name of your service? " name
	if ! mkdir "$DATABASE/$name"; then
		exit 1
	fi
	read -s -r -p "Enter your TOTP secret (not visible in terminal): " secret
	echo "Now enter a password which will be used for encrypting the secret."
	echo "IT IS NOT RECOVERABLE, IF YOU LOSE IT - YOU WILL HAVE TO RE-ENABLE 2FA BY USING RECOVERY CODES!"
	read -s -r -p "Password (not visible in terminal): " password
	echo "$secret" | openssl aes-256-cbc -pbkdf2 -k "$password" -out "$DATABASE/$name/totp"
	echo
	echo "Added!"
	echo "Now try using ./totp.sh open"
	exit 0
fi

if [[ $1 == "open" ]]; then
	echo "Enter the name of your service (located in database folder)."
	read -r -p "Name: " name
	if ! cd "$DATABASE/$name"; then
		exit 1
	else
		cd - > /dev/null
		read -s -r -p "Password (not visible in terminal): " password
		secret=$(openssl aes-256-cbc -d -pbkdf2 -k "$password" -in "$DATABASE/$name/totp")
		echo
		oathtool -b --totp "$secret"
		exit 0
	fi
fi

echo "I don't know what do you mean by $1"
