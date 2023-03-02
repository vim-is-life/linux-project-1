#!/usr/bin/env sh

# 123149
# 1 March 2023
# Linux Project 1

# Script is intended to run to set up the pi zero for my project from the moment
# after user initialization.
#
# Wifi should be set up and git installed before running this script. Download it like the below.
#   git clone https://github.com/vim-is-life/linux-project-1.git
# And then run the script like the below
#   ./setup.sh

PACKAGES="$(tr <PACKAGES '\n' ' ')"
SSH_PORT="$(awk '/ssh/ {print $2}' PORTS)"
HTTP_PORT="$(awk '/http/ {print $2}' PORTS)"

# INSTALL PACKAGES ############################################################
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install "$PACKAGES"

# SET UP FIREWALL #############################################################
# to set defaults to deny incoming traffic and allow outgoing and then open
# ports as necessary
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow "$HTTP_PORT"
sudo ufw allow "$SSH_PORT"
sudo ufw enable

# SET UP SSH ##################################################################
# change default ssh port in config
# disallow root login
# only allow public key auth and deny passwords
sed -E "s/#Port 22/Port $SSH_PORT/
s/(PermitRootLogin) yes/\\1 no/
s/#(PasswordAuthentication) yes/\\1 no/
s/#(PubkeyAuthentication yes)/\\1/
s/(UsePAM) yes/\\1 no/" ./config/ssh/sshd_config

# enable the ssh service immediately
sudo systemctl enable --now ssh

# SET UP SERVER ###############################################################
sudo mkdir -p /var/www/seminar/html -p
sudo chown -R $USER:$USER /var/www/seminar/html
sudo chmod -R 755 /var/www/seminar
# copy the forbes front page as our index.html to make things simpler
curl -fLo /var/www/seminar/index.html 'https://www.forbes.com/'
# take config file, copy to sites-available, then symlink to sites-enabled
sudo cp ./config/nginx/seminar /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/seminar /etc/nginx/sites-enabled/seminar
sudo systemctl restart nginx

# TESTS #######################################################################
