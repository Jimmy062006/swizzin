#!/bin/bash
# ruTorrent removal
# Author: liara

users=($(cut -d: -f1 < /etc/htpasswd))

rm -rf /srv/rutorrent
rm -rf /etc/nginx/apps/rutorrent.conf

if ! is_installed flood; then
	rm -rf /etc/nginx/apps/rindex.conf
	for u in "${users[@]}"; do
		rm -f /etc/nginx/apps/${u}.scgi.conf
	done
fi

unmark_installed "rutorrent"
systemctl reload nginx
