#!/bin/sh
ethermintd --home /ethermint/node$VersoriumX/ethermintd/ start > ethermintd.log &
sleep 5
ethermintcli rest-server --laddr "tcp://localhost:8545" --chain-id 11011 --trace > ethermintcli.log &
tail -f /dev/null
