#!/bin/bash

#shellcheck source=sources/functions/utils
. /etc/swizzin/sources/functions/utils
master=$(_get_master_username)
distribution=$(lsb_release -is)

airsonicdir="/opt/airsonic" #Where to install airosnic
airsonicusr="airsonic"      #Who to run airsonic as

#shellcheck source=sources/functions/java
. /etc/swizzin/sources/functions/java
install_java8

echo_progress_start "Downloading Airsonic binary"
mkdir $airsonicdir -p
# TODO make dynamic
dlurl=$(curl -s https://api.github.com/repos/airsonic/airsonic/releases/latest | grep "browser_download_url" | grep "airsonic.war" | head -1 | cut -d\" -f 4)
wget "$dlurl" -O ${airsonicdir}/airsonic.war >> "$log" 2>&1
useradd $airsonicusr --system -d "$airsonicdir" >> "$log" 2>&1
usermod -a -G "$master" $airsonicusr
sudo chown -R $airsonicusr:$airsonicusr $airsonicdir
echo_progress_done "Binary DL'd"

echo_progress_start "Setting up systemd service"
wget https://raw.githubusercontent.com/airsonic/airsonic/master/contrib/airsonic.service -O /etc/systemd/system/airsonic.service >> "$log" 2>&1
sed -i "s|/var/airsonic|$airsonicdir|g" /etc/systemd/system/airsonic.service
sed -i 's|PORT=8080|PORT=8185|g' /etc/systemd/system/airsonic.service

defconfdir="/etc/sysconfig"
if [[ $distribution == "Debian" ]]; then
	defconfdir="/etc/defaults"
fi
wget https://raw.githubusercontent.com/airsonic/airsonic/master/contrib/airsonic-systemd-env -O "${defconfdir}"/airsonic >> "$log" 2>&1

systemctl daemon-reload -q
echo_progress_done "Service installed"

if [[ -f /install/.nginx.lock ]]; then
	echo_progress_start "Configuring nginx"
	bash /usr/local/bin/swizzin/nginx/airsonic.sh
	systemctl reload nginx
	echo_progress_done
else
	echo_info "Airosnic will run on <IP/domain.tld>${bold}:8185"
fi

echo_progress_start "Enabling and starting Airsonic"
systemctl -q enable airsonic --now
echo_progress_done

echo_success "Airsonic installed"
echo_warn "Wait for Airsonic to start up and continue the set up in the browser to change the username and password."

if [[ -f /install/.subsonic.lock ]]; then
	echo_info "If you would like to perform a migration, please see see the following article"
	echo_docs "applications/airsonic#migrating-from-subsonic"
fi
touch /install/.airsonic.lock