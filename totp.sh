#!/usr/bin/env bash
# shellcheck disable=2164
DATABASE="./database"
KEYID=""
SYMMETRIC=0

if [ -z $DATABASE ]; then
	echo "FATAL: Missing DATABASE variable!"
	exit 1
fi

if [ -z $KEYID ] && [[ $SYMMETRIC -eq 0 ]]; then
	echo "FATAL: Missing KEYID variable!"
	echo "If you want to use symmetric encryption, please set SYMMETRIC variable to 1 or use OpenSSL version (not recommended)."
	exit 1
fi

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
	if [[ $SYMMETRIC -eq 1 ]]; then
		echo "$secret" | gpg -a -c --pinentry-mode loopback --output "$DATABASE/$name/totp"
	else
		echo "$secret" | gpg -e -a -r "$KEYID" --output "$DATABASE/$name/totp" --pinentry-mode loopback
	fi
	echo "Added!"
	echo "Now try using ./totp.sh open"
	exit 0
fi

if [[ $1 == "open" ]]; then
	read -r -p "Enter the name of your entry (located in database folder): " name
	if [ -z $name ]; then
		echo "No name specified!"
		exit 1
	fi
	if ! cd "$DATABASE/$name"; then
		exit 1
	else
		cd - > /dev/null
		echo
		oathtool -b --totp $(gpg --pinentry-mode loopback -d "$DATABASE/$name/totp")
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
exit 1
