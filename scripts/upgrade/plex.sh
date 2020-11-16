#!/bin/bash
# Install updateplex by mrworf
# https://github.com/mrworf/plexupdate

if ! is_installed plex; then
	echo_error "Plex doesn't appear to be installed. What do you hope to accomplish by running this script?"
	exit 1
fi

if ! is_installed updateplex; then
	user=$(cut -d: -f1 < /root/.master.info)
	sudo -H -u $user bash -c "$(wget -qO - https://raw.githubusercontent.com/mrworf/plexupdate/master/extras/installer.sh)"
	# In case I need this file to do more than install updateplex in the future (unlikely)
	mark_installed "updateplex"
fi

# Yes that's it, get outta here you dirty club rats
