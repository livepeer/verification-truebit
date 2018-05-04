#!/bin/sh

echo plort > supersecret.txt
mkdir -p ~/.local/share/io.parity.ethereum/chains/kovan/
if [ ! -f ~/.local/share/io.parity.ethereum/chains/kovan/myaddress ]
then
  parity --chain kovan account new --password=supersecret.txt > ~/.local/share/io.parity.ethereum/chains/kovan/myaddress
fi

service apache2 start
service mongodb start

parity --chain kovan --unlock=`cat ~/.local/share/io.parity.ethereum/chains/kovan/myaddress` --password=supersecret.txt --ws-hosts=all --ws-origins=all &
sleep 10

cd verification-truebit
node setup.js kovan.json > config.json

cd ../webasm-solidity/node
node setup.js kovan.json > config.json
node app.js

