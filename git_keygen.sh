#!/bin/bash
# Prompt for email
echo "Enter a github email: " 
read github_email
while [[ -z $github_email ]];do
    read -p "Enter an email to continue! > " github_email
done

# generate new keys
echo "#Optional: Choose a key name: "  
read -p "Press [ENTER] to continue with the default [$HOME/.ssh/github_key]  " github_key
github_key=${github_key:-'github_key'}

ssh-keygen -t rsa -b 4096 -C $github_email -f "$HOME/.ssh/$github_key"

# check for running deamon
eval "$(ssh-agent -s)"
if [ $# -ne 0 ]
    then
    echo -e '\e[0;31m'"Failed to allocate ssh-agent deamon...please check it manually!"'\e[0m'
fi

# Prompt for username
echo "Enter a github username: " 
read github_username
while [[ -z $github_username ]];do
    read -p "Enter github username > " github_username
done

end_point="https://api.github.com/user/keys"

public_key="$(cat $HOME/.ssh/$github_key'.pub')"

# Escape chars looks nasty but github API is picky to double quotes
output="$(curl -u "$github_username" -d "{\"title\":\"$HOSTNAME\",\"key\":\"$public_key\" }" $end_point)"

while echo $output | egrep -i -w 'Requires authentication|Bad credentials';do
    echo "Failed!!-- retry..."
output="$(curl -u "$github_username" -d "{\"title\":\"$HOSTNAME\",\"key\":\"$public_key\" }" $end_point)"
done

if [[ $? -eq 0 ]] && echo $output | egrep -i -w 'id|name|key';then
    printf '\e[0;32m'" The public-key %s  has been added successfully to your github account %s\n"'\e[0m' $github_key  $github_username
fi

