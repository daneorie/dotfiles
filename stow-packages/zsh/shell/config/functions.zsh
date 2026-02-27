# Shell Functions

# Work-specific functions (C1)
function awsCredentials {
	cloudsentry access get --account ${1:-$AWS_PROFILE} --ba ${2:-$BA}
}

# Git functions
function gc {
	git clone git@github.com:ORG/backend.git "$1" && cd "$1" && git checkout "$1"
}

function mergeMain {
	cd ../main && git pull && git merge main && npm run install:all
}

# Text processing functions
function reverseOrder {
	grep -n "" | sort -rn | sed 's/^[0-9]*://'
}

function readresponse {
	gunzip -c | jq
}

function readbody {
	read body
	if [[ -n "$body" ]]; then
		echo "$body" | base64 --decode | gunzip -c | jq
	else
		echo "$1" | base64 --decode | gunzip -c | jq
	fi
}

function urldecode {
	read url
	if [[ -n "$url" ]]; then
		echo "$url" | echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
	else
		echo "$1" | echo -e "$(sed 's/+/ /g;s/%\(..\)/\\x\1/g;')"
	fi
}

# Utility functions
function define() {
	/usr/local/bin/define $* | grep -n "." | sort -nr | sed '1,4d' | sort -n | sed 's/^[0-9]*://' | $PAGER
}

function c() {
    $HOME/dotfiles/shell/scripts/cht.sh "$@" | $PAGER
}

function rmpwd {
	dir="$(pwd)"
	cd ..
	rm -rf "$dir"
}