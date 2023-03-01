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
sed "s/#Port 22/Port $SSH_PORT/
s/(PermitRootLogin) yes/\1 no/
s/#(PubkeyAuthentication yes)/\1/
s/(UsePAM) yes/\1 no/"

# SET UP SERVER ###############################################################
