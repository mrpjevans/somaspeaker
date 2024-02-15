#!/bin/bash

cat > /usr/lib/systemd/somaspeaker.service << EOF
[Service]
WorkingDirectory=$(pwd)
ExecStart=/usr/local/bin/flask --app $(pwd)/somaspeaker.py run -h 0.0.0.0 -p 3000
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable /usr/lib/systemd/somaspeaker.service
sudo systemctl start somaspeaker.service

