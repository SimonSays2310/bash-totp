#!/usr/bin/env bash
# shellcheck disable=2164
DATABASE="./database"

if [ -z "$1" ]; then
	echo "Usage: ./totp.sh add"
	echo "       ./totp.sh open"
	echo "       ./totp.sh delete"
	exit 1
fi

if [[ $1 == "add" ]]; then
	read -r -p 'Enter the name of your new entry (typically this should be a name of service where do you want to enable 2FA, for example "Email", "Git server" etc): ' name
	if [ -z "$name" ]; then
		echo "No name specified!"
		exit 1
	fi
	if ! mkdir "$DATABASE/$name"; then
		exit 1
	fi
	read -s -r -p "Enter your TOTP secret (not visible in terminal): " secret
	echo "Now enter a password which will be used for encrypting the secret."
	echo "IT IS NOT RECOVERABLE, IF YOU LOSE IT - YOU WILL HAVE TO RE-ENABLE 2FA BY USING RECOVERY CODES!"
	read -s -r -p "Password (not visible in terminal): " password
	echo
	read -s -r -p "Retype password: " password2
	echo
	if ! [[ $password == $password2 ]]; then
		echo "Passwords mismatch, please try again!"
		rm -rf "$DATABASE/$name/"
		exit 1
	fi
	echo "$secret" | openssl aes-256-cbc -pbkdf2 -k "$password" -out "$DATABASE/$name/totp"
	echo "Added!"
	echo "Now try using ./totp.sh open"
	exit 0
fi

if [[ $1 == "open" ]]; then
	read -r -p "Enter the name of your entry (located in database folder): " name
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

if [[ $1 == "delete" ]]; then
	read -r -p "Enter the name of entry which should be deleted (located in database folder): " name
	if [ -z "$name" ]; then
		echo "No name specified!"
		exit 1
	fi
	if ! ls "$DATABASE/$name" > /dev/null; then
		exit 1
	else
		read -r -p "Are you sure that you want to delete this entry? This cannot be undone! (Y/N) " answer
		if [[ $answer == Y ]] || [[ $answer == y ]]; then
			# shellcheck disable=2115
			rm -rf "$DATABASE/$name"
			echo "Deleted!"
		fi
	fi
exit 0
fi


echo "I don't know what do you mean by $1"
