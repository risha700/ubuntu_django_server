 # Ubuntu server setup for django, systemd,statsd, graphite and grafana with a simple script
 ### get started
```bash
wget -I -k https://github.com/risha700/ubuntu_django_server/archive/master.zip
unzip master.zip && rm -rf master.zip && cd ubuntu_django_server-master

```
### initiate the script

```bash
./server_provision.sh
```

### optional: generate ssh keys and add it to your github account from the cli 
### you will be prompt for your credentials as a friendly UI
```bash
./git_keygen.sh

# optional param:userpath[/home/username] 
./git_keygen /home/root
```
### useful debug for github ssh access
```bash
# check git permission 
ssh -T git@github.com
# 'ssh-agent -s' sometimes it doesn't export the newly generated $SSH_AGENT_PID 
# this wroks great
eval `ssh-agent -s`
# add to keychain if needed
ssh-add path/.ssh/gitkey

```
