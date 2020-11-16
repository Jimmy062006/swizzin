#!/bin/bash
# Flood uninstaller
# Author: liara

users=($(cut -d: -f1 < /etc/htpasswd))
for u in "${users[@]}"; do
	systemctl disable -q flood@$u
	systemctl stop -q flood@$u
	rm -rf /home/$u/.flood
	rm -rf /etc/nginx/conf.d/$u.flood.conf
done
rm -rf /etc/nginx/apps/flood.conf
if ! is_installed rutorrent; then
	rm -rf /etc/nginx/apps/rindex.conf
	rm -f /etc/nginx/apps/${u}.scgi.conf
fi
rm -rf /etc/systemd/system/flood@.service
systemctl reload nginx

unmark_installed "flood"

users=($(cut -d: -f1 < /etc/htpasswd))
