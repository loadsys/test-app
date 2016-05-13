#!/usr/bin/env bash

#---------------------------------------------------------------------
usage ()
{
	cat <<EOT

${0##*/}
    Thin script included with new projects to make it easier to
    bootstrap a freshly cloned repository.

    At minimum, this script initializes submodules and runs composer.

    Project provisioning is kicked off via vagrant for dev
    environments, and directly via the provisioning shell scripts in
    all others (staging, production).

Usage:
    bin/${0##*/} <APP_ENV>


EOT

	exit 0
}
if [ "$1" = '-h' ]; then
	usage
fi

# Set up working vars.
if [ -z "$1" ]; then
	usage
fi
NEW_APP_ENV=${1}

DIR="$( cd -P "$( dirname "$0" )"/. >/dev/null 2>&1 && pwd )"

echo "## Bootstrapping the project."


# Initialize git.
cd "${DIR}"

if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "## Initializing git submodules."
    git submodule update --init --recursive
fi


# If we have a Vagrantfile, the `vagrant` command and APP_ENV=vagrant,
# run `vagrant up` to get the VM created and provisioned.
VAGRANT_CONFIG_FILE="$DIR/Vagrantfile"

VAGRANT="$( which vagrant )"

# Checking specifically for `vagrant` here is a magic string, but what can we do?
if [ $? -eq 0 ] && [ -e "$VAGRANT_CONFIG_FILE" ] && [ "$NEW_APP_ENV" = "vagrant" ]; then

    echo "## Found Vagrant: ${VAGRANT}"
    echo "## Found Vagrant config file: $VAGRANT_CONFIG_FILE"
    echo "## Provisioning for development."

    vagrant up

# Otherwise provision "bare metal" for the APP_ENV provided.
else

    echo "## Provisioning for bare metal with APP_ENV=${NEW_APP_ENV}."

    read -t 60 -p "Proceed? (Ctrl-C to abort.) [ENTER] " NOOP

    provision/main.sh ${NEW_APP_ENV}

	# Bring APP_ENV into scope immediately.
	. ~/.profile
fi


# Finish up.
echo "## Done: `basename "$0"`"
