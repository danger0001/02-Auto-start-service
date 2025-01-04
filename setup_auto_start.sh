#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]
  then echo "请以root权限运行这个脚本"
  exit
fi

echo "请输入你的启动命令（例如：screen -S t3rn -d -m /bin/bash -c 'cd /root/t3rn-bot && python3 bot.py'）："
read COMMAND

SERVICE_NAME="auto_start_service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
WORKING_DIR="/root"

cat << EOF > "$SERVICE_FILE"
[Unit]
Description=Auto Start Service
After=network.target

[Service]
Type=forking
ExecStart=$COMMAND
ExecStop=/usr/bin/screen -S auto_session -X quit
Restart=always
User=root
WorkingDirectory=$WORKING_DIR

[Install]
WantedBy=multi-user.target
EOF

# 设置权限
chmod 644 "$SERVICE_FILE"
chmod +x "$WORKING_DIR"/* -R

# 重新加载服务
systemctl daemon-reload

# 启用服务
systemctl enable "$SERVICE_NAME".service

# 启动服务
systemctl start "$SERVICE_NAME".service

echo "服务已创建并启动。检查状态使用："
echo "systemctl status $SERVICE_NAME.service"
echo "查看日志使用："
echo "journalctl -u $SERVICE_NAME.service -n 50"