#!/bin/sh

# source /emsdk/emsdk_env.sh

if [ ! -f supersecret.txt ]
then
  echo "" > supersecret.txt
fi

service apache2 restart
service mongodb restart

ipfs daemon &
parity --chain dev --unlock=0x00a329c0648769a73afac7f9381e08fb43dbea72 --no-discovery --reseal-min-period 0 --password=supersecret.txt --ws-hosts=all --ws-origins=all &

sleep 10

cd /webasm-solidity/node
node deploy-tasks.js | tee config.json
node app.js &

sleep 10

cd /verification-truebit

node deploy.js | tee config.json

node post.js data/correct.ts

