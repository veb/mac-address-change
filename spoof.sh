#!/bin/bash

if [ $# -eq 0 ]
	then
	echo "An interface must be required"
	exit 1
fi

echo ""
echo ""
echo "Changing MAC on interface: $1"
echo ""
echo "Current MAC: $(sudo ifconfig $1 | grep ether)"

ADDRESS=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//')
sudo ifconfig $1 ether $ADDRESS
sudo ifconfig $1 down
sudo ifconfig $1 up

echo "New MAC: $(ifconfig $1 | grep ether)"
echo ""
echo ""
