# OUTPUT-COLORING
red='\e[0;31m'
green='\e[0;32m'
reset='\e[0m'

function confirm_choice () {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

# param $1: keygen file path
# param $2: user home path
function check_git_ssh (){
    _git_stat=`ssh -T git@github.com 2>&1`
    if ! echo $_git_stat | egrep -i -w 'Hi|successfully authenticated,';then
        echo -e $green"generating new github ssh keys..."$reset
        if [[ $# -eq 0 ]];then
            ${0%/*}/git_keygen.sh
        else
            $1/git_keygen.sh $2
        fi
    fi
}

function create_python_env (){
    sudo -S python3 -m venv $1/.venv
    if [[ $? -eq 0 ]];then
        sudo -H $1/.venv/bin/pip install django gunicorn psycopg2-binary
    fi
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
function proceed_cloning_git_repo (){
        echo 'Cool...please enter your repo link [SSH]'
        read -p "Enter repo url [ git@github.com:username/repo.git ]" repo_url
        while [[ -z $repo_url ]];do
            read -p "Repository URL to continue " repo_url
        done
        git clone $repo_url
}

function proceed_creating_bare_django_app (){
    echo 'installing django'
    django-admin.py startproject $appname ~/appname

}

function install_app_options (){
    install_app_options=( "Link your github repo" "Install bare django app" "Quit")
    select opt in "${install_app_options[@]}"
    do
        case $opt in
        "Link your github repo")
        proceed_cloning_git_repo
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