function check_git_ssh (){
    _git_stat=`ssh -T git@github.com 2>&1`
    if ! echo $_git_stat | egrep -i -w 'Hi|successfully authenticated,';then
        echo "generating new github ssh keys..."
        ${0%/*}/git_keygen.sh
    fi
}

function create_python_env (){
    cd $1
    sudo -S python3 -m venv .venv
    # source $1/.venv/bin/activate
    sudo -H $1/.venv/bin/pip install django gunicorn psycopg2-binary
}   
function request_machine_username (){
    # Prompt to obtain a username
    printf "Enter a username > \n"
    read  username
    while [[ -z $username ]];do  
        printf ${red}"Enter valid username >${reset}\n"
        read username
    done
}

function request_app_name (){
    # Prompt to obtain a app name
    printf "Enter an App name > \n"
    read  appname
    while [[ -z $appname ]];do  
        printf ${red}"Enter valid App Name >${reset}\n"
        read appname
    done
}