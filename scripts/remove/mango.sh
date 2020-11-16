#! /bin/bash
# Mango deyeeter by flying_sausages 2020 for swizzin

rm -rf /opt/mango
systemctl disable --now -q mango
rm /etc/systemd/system/mango.service
systemctl daemon-reload -q

if is_installed nginx; then
	rm /etc/nginx/apps/mango.conf
	systemctl reload nginx
fi

userdel mango -f -r >> $log 2>&1

unmark_installed "mango"
