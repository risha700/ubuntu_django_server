## missing parts
# create gunicorn service
- sudo nano /etc/systemd/system/gunicorn.socket
# config
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn.sock

[Install]
WantedBy=sockets.target

- sudo nano /etc/systemd/system/gunicorn.service
# config
[Unit]
Description=gunicorn daemon
Requires=gunicorn.socket
After=network.target

[Service]
User=postmaster
Group=www-data
WorkingDirectory=/home/postmaster/elifehub/app
ExecStart=/home/postmaster/elifehub/.venv/bin/gunicorn \
          --access-logfile - \
          --error-logfile /var/log/gunicorn.log \
          --workers 3 \
          --bind unix:/run/gunicorn.sock \
          app.wsgi:application

ExecStart=/home/postmaster/elifehub/.venv/bin/gunicorn --access-logfile - --workers 3 \
                --bind unix:/run/gunicorn.sock app.wsgi:application \
                --access-logformat "%({x-forwarded-for}i)s %(l)s %(u)s %(t)s \"%(r)s\" %(s)s %(b)s \"%(f)s\" \"%(a)s\""
[Install]
WantedBy=multi-user.target


sudo systemctl start gunicorn.socket
sudo systemctl enable gunicorn.socket

# debug
sudo systemctl status gunicorn.socket
file /run/gunicorn.sock
sudo journalctl -u gunicorn.socket
sudo systemctl status gunicorn
curl --unix-socket /run/gunicorn.sock localhost
sudo systemctl status gunicorn
sudo journalctl -u gunicorn

sudo systemctl daemon-reload
sudo systemctl restart gunicorn

# configure ngnix
sudo nano /etc/nginx/sites-available/e-lifehub.com

# config
server {
    listen 80;
    server_name server_domain_or_IP;

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root /home/sammy/myprojectdir;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/run/gunicorn.sock;
    }
}


sudo ln -s /etc/nginx/sites-available/e-lifehub.com /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx


# enable firewall
ufw app list
sudo ufw delete allow 8000
sudo ufw allow 'Nginx Full'
sudo ufw allow ssh
sudo ufw allow OpenSSH
sudo ufw status





create wildcard cert certbot
# https://certbot.eff.org/lets-encrypt/ubuntubionic-nginx
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update

sudo apt-get install python3-certbot-dns-digitalocean
# https://certbot-dns-digitalocean.readthedocs.io/en/stable/index.html#credentials
certbot certonly \
  --dns-digitalocean \
  --dns-digitalocean-credentials ~/.secrets/certbot/digitalocean.ini \
  -d "*.example.com,example.com "

# or but no auto renewal 
sudo certbot --server https://acme-v02.api.letsencrypt.org/directory -d *.example.com --manual --preferred-challenges dns-01 certonly


## final ngnix config

--config

server {
  listen 80;
  listen [::]:80;
  server_name *.e-lifehub.com;
  return 301 https://$host$request_uri;
}
server {
  listen 443 ssl;
  server_name e-lifehub.com;
  ssl_certificate /etc/letsencrypt/live/e-lifehub.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/e-lifehub.com/privkey.pem;
  return 301 https://www.e-lifehub.com$request_uri;

}

server {
  listen 443 ssl;
  server_name *.e-lifehub.com;
  ssl_certificate /etc/letsencrypt/live/e-lifehub.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/e-lifehub.com/privkey.pem;
  #include /etc/letsencrypt/options-ssl-nginx.conf;
  #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
  root /var/www/elifehub;
  location / {
    
    set $maintenance off;
    if (-f $document_root/maintenance.html) {
      set $maintenance on;
    }
    if ($remote_addr ~ (206.255.161.14)) {
      set $maintenance off;
      }
    if ($maintenance = on) {
      return 503;
    }

    include proxy_params;
    proxy_pass http://unix:/run/gunicorn.sock;
    
  }
  error_page 503 @maintenance;
  location @maintenance {
        rewrite ^(.*)$ /maintenance.html break;
  }
location /static/ {
    alias /home/postmaster/elifehub/app/static/;
    }
    

}

server{
        server_name e-lifehub.com;
        listen 80;
        listen [::]:80;
        return 301 https://www.e-lifehub.com$request_uri;
}
certbot certonly --dns-digitalocean --dns-digitalocean-credentials ~/.secrets/certbot/digitalocean.ini -d "*.e-lifehub.com" -d e-lifehub.com


## change media permission

sudo chgrp -R www-data media/
sudo chmod -R 770 /var/www/media/
chmod g+s /var/www/media




## Unix Debug info

# memeory
vmstat -s
cat /proc/meminfo
free -m
# Cpu
top
htop
# ram
sudo dmidecode -t 17

# 
df -h
lsof -i 
netstat -nutlp
# block id
blkid
netstat -lnp | grep redis 
# timezone
dpkg-reconfigure tzdata