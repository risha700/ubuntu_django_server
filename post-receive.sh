#!/bin/bash
TARGET="/home/postmaster/elifehub"
GIT_DIR="/var/git/app.git"
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

cd $TARGET
source .venv/bin/activate
if [[ $? -eq 0 ]];then
   pip install --upgrade pip
   pip install -r requirements.txt
fi
cd `echo $TARGET/app`
python manage.py migrate_schemas || python manage.py migrate_schemas --fake-initial
python manage.py collectstatic -c --noinput
python manage.py test
sudo systemctl daemon-reload
sudo systemctl restart gunicorn
sudo systemctl restart nginx
sudo systemctl restart redis