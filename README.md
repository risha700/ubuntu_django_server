 # Ubuntu server setup for django, systemd,statsd, graphite and grafana with a simple script
 ### get started
```bash
wget -I -k https://github.com/risha700/ubuntu_django_server/archive/master.zip
unzip master.zip && rm -rf master.zip && cd ubuntu_django_server-master

```
### initiate the script

```bash
sudo ./server_provision.sh
```

### optional: generate ssh keys and add it to your github account from the cli 
### you will be prompt for your credentials as a friendly UI
```bash
./git_keygen.sh
```
