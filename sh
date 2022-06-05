#!/bin/bash
systemctl stop subspace-node.service subspace-farmer.service
rm -r /data/sub/
rm -r /root/.local/share/subspace-farmer/
wget https://github.com/subspace/subspace/releases/download/gemini-1b-2022-june-03/subspace-node-ubuntu-x86_64-gemini-1b-2022-june-03 -O /root/sub/subspace-node
wget https://github.com/subspace/subspace/releases/download/gemini-1b-2022-june-03/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-june-03 -O /root/sub/subspace-farmer
chmod +x /root/sub/subspace*
cat >/etc/systemd/system/subspace-farmer.service << eof
[Unit]
Description = subspace
After = network.target
[Service]
User = root
Type = simple
Restart = always
RestartSec = 30
WorkingDirectory = /root/sub/
#ExecStart = /root/sub/subspace-farmer --base-path /data/sub/farm farm --reward-address stBKunQzkQhLiVmKc85cUEJoe6gsYTwtj1ZLSA7zH5tMsF3pT --plot-size 40G
ExecStart = /root/sub/subspace-farmer --base-path /data/sub/farm farm --reward-address $2 --plot-size $3G
ExecStopPost = /bin/echo service down
LimitNOFILE=65535
[Install]
WantedBy = multi-user.target
eof
cat >/etc/systemd/system/subspace-node.service << eof
[Unit]
Description = subspace
After = network.target
[Service]
User = root
Type = simple
Restart = always
RestartSec = 30
WorkingDirectory = /root/sub/
ExecStart = /root/sub/subspace-node --base-path /data/sub --chain gemini-1 --execution wasm --pruning 1024 --keep-blocks 1024 --validator --name $1
ExecStopPost = /bin/echo service down
LimitNOFILE=65535
[Install]
WantedBy = multi-user.target
eof
systemctl daemon-reload
systemctl restart subspace-farmer.service subspace-node.service
systemctl enable subspace-node.service subspace-farmer.service
