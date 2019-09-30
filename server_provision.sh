#!/bin/bash
source ${0%/*}/utils.sh
echo -e $green"Enter sudo password to start..."$reset

# Update ubuntu
sudo apt update -y && sudo apt upgrade -y
echo "Initializing $HOSTNAME setup..."
# Utils func 
request_machine_username
request_app_name

# Add the user
sudo adduser $username
# Elevalate sudo priviliges in the root level
sudo usermod -aG sudo $username
sudo mkdir -pv /home/$username/$appname
if [[ $? -eq 0 ]];then echo -e $green"Folder created $appname"$reset;fi
sudo chown -R $username:$username /home/$username/


DJANGO_SECRET_KEY=`openssl rand -base64 48`
DBPASSWORD=`openssl rand -base64 32`

# export DJANGO_SETTINGS_MODULE=$APPNAME.settings.production # settings file for the app
# export PYTHONPATH=\$DJANGODIR:\$PYTHONPATH
export SECRET_KEY="echo $DJANGO_SECRET_KEY"
export DB_PASSWORD="echo $DBPASSWORD"
# Setting up server packages
sudo apt install -y python3-pip python3-dev python3-venv libpq-dev postgresql postgresql-contrib nginx curl git
sudo -u postgres psql <<EOF
    CREATE DATABASE $appname;
    CREATE USER $username WITH PASSWORD '$DBPASSWORD';
    ALTER ROLE $username SET client_encoding TO 'utf8';
    ALTER ROLE $username SET default_transaction_isolation TO 'read committed';
    ALTER ROLE $username SET timezone TO 'UTC';
    GRANT ALL PRIVILEGES ON DATABASE $appname TO $username;
    \q
EOF
# Setup python env
create_python_env /home/$username
sudo mkdir -pv /home/$username/.ssh/
#sudo chmod 700 /home/$username/.ssh
sudo chown -R $username:$username /home/$username/.ssh
check_git_ssh $PWD /home/$username
sudo chown -R $username:$username /home/$username/.ssh/**
install_app_options