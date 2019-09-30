#!/bin/bash
#set $HOME env 
if [[ -n $1 ]];then
HOME="$1"
echo $HOME
fi
# Prompt for email
read -p "Enter a github email: " github_email
while [[ -z $github_email ]];do
    read -p "Enter an email to continue! > " github_email
done
# generate new keys
echo "Choose a key name OR "  
read -p "Press [ENTER] to continue with the default [$HOME/.ssh/github_key]  " github_key
github_key=${github_key:-'github_key'}

ssh-keygen -t rsa -b 4096 -C $github_email -f "$HOME/.ssh/$github_key"

# check for running deamon and define its env vars
eval `ssh-agent -s`
# add key to ssh keychain
ssh-add $HOME/.ssh/$github_key

# Prompt for username
read -p  "Enter a github username: " github_username
while [[ -z $github_username ]];do
    read -p "Enter github username > " github_username
done

end_point="https://api.github.com/user/keys"

public_key="$(cat $HOME/.ssh/$github_key'.pub')"

# Escape chars looks nasty but github API is picky to double quotes
output="$(curl -u "$github_username" -d "{\"title\":\"$HOSTNAME\",\"key\":\"$public_key\" }" $end_point)"

while echo $output | egrep -i -w 'Requires authentication|Bad credentials';do
    echo -e $red"Failed password attempt !! retry..."$reset
output="$(curl -u "$github_username" -d "{\"title\":\"$HOSTNAME\",\"key\":\"$public_key\" }" $end_point)"
done

if [[ $? -eq 0 ]] && echo $output | egrep -i -w 'id|name|key';then
    printf '\e[0;32m'" The public-key %s  has been added successfully to your github account %s\n"'\e[0m' $github_key  $github_username
fi

