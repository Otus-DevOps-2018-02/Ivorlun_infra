#! /bin/bash
# Deploys Reddit App from source
set -e
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
cat << EOF > /etc/systemd/system/puma.service
[Unit]
Description=Puma HTTP Server
After=network.target
[Service]
Type=simple
User=$USER
WorkingDirectory=$PWD
ExecStart=/usr/local/bin/puma -b tcp://0.0.0.0:9292
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable puma
