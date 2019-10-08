# OUTPUT-COLORING
red='\e[0;31m'
green='\e[0;32m'
reset='\e[0m'

confirm_choice () {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

# param $1: keygen file path
# param $2: user home path
check_git_ssh (){
    if [[ $# -gt 0 ]];then
    CSU=`echo $2|awk -F"/" '{print $NF}'`
    export $CSU
    _git_stat=`sudo -i -u $CSU ssh -T git@github.com 2>&1`
    else
    _git_stat=`ssh -T git@github.com 2>&1`
    fi
    if ! echo $_git_stat | egrep -i -w 'Hi|successfully authenticated,';then
        echo -e $green"generating new github ssh keys..."$reset
        if [[ $# -eq 0 ]];then
            ${0%/*}/git_keygen.sh
        else
            sudo -i -u $CSU $1/git_keygen.sh $2
        fi
    fi
}

create_python_env (){
    sudo -S python3 -m venv $1/.venv
    if [[ $? -eq 0 ]];then
        sudo -H $1/.venv/bin/pip install django gunicorn psycopg2-binary
    fi
}
request_machine_username (){
    # Prompt to obtain a username
    printf "Enter a username > \n"
    read  username
    while [[ -z $username ]];do  
        printf ${red}"Enter valid username >${reset}\n"
        read username
    done
}

request_app_name (){
    # Prompt to obtain a app name
    printf "Enter an App name > \n"
    read  appname
    while [[ -z $appname ]];do
        printf ${red}"Enter valid App Name >${reset}\n"
        read appname
    done
}
request_github_repo(){
    echo 'Cool...please enter your repo link [SSH]'
    read -p "Enter repo url [ git@github.com:username/repo.git ]" repo_url
    while [[ -z $repo_url ]];do
        read -p "Repository URL to continue " repo_url
    done
}

prepare_ssh_agent(){
    eval `ssh-agent -s`
    echo $SSH_AGENT_PID
    ssh-add ~/.ssh/github_key
}

proceed_cloning_git_repo(){
sudo -H -i -u $username bash -l<<EOF
    source $PWD/utils.sh
    prepare_ssh_agent
    git clone $repo_url
    add_source_control
    echo -e "$greenYour github source control is ready..$reset"
EOF
}

# FOR TESTING ONLY
proceed_creating_bare_django_app (){
    echo 'installing django'
    django-admin.py startproject $appname ~/$appname

}

install_app_options (){
    install_app_options=( "Link your github repo" "Install bare django app" "Quit")
    select opt in "${install_app_options[@]}"
    do
        case $opt in
        "Link your github repo")
        request_github_repo
        if [[ $? -eq 0 ]];then
        proceed_cloning_git_repo
        fi
        break
        ;;
        "Install bare django app")
        proceed_creating_bare_django_app
        break
        ;;
        "Quit")
        confirm_choice "Are you sure, quit?"
        break
        ;;
        *) echo "invalid option $REPLY";;

        esac
    done
}

add_source_control(){
    # set up auto deploy
    SRC_CTL='app.git'
    git init --bare $HOME/$SRC_CTL
    cat > $HOME/$SRC_CTL/hooks/post-receive <<EOF
        #!/bin/bash
        TARGET= "echo $HOME/$appname"
        GIT_DIR= "echo $HOME/$SRC_CTL"
        BRANCH="master"
        while read oldrev newrev ref
        do
            # only checking out the master (or whatever branch you would like to deploy)
            if [ "$ref" = "refs/heads/$BRANCH" ];
            then
                echo "Ref $ref received. Deploying ${BRANCH} branch to production..."
                git --work-tree=$TARGET --git-dir=$GIT_DIR checkout -f $BRANCH
            else
                echo "Ref $ref received. Doing nothing: only the ${BRANCH} branch may be deployed on this server."
            fi
        done
EOF
    wait $!
    sudo chmod +x $HOME/$SRC_CTL/hooks/post-receive
}