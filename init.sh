#!/bin/bash

KEY="mykey"
CHAINID=0x4353
MONIKER="localhost"
# Install Ethermint dependencies
echo -e "Installing Ethermint dependencies...\n"
sudo apt-get update
sudo apt-get install -y build-essential jq git curl
# Install Go
GO_VERSION="1.20.5"
if ! command -v go &> /dev/null; then
    echo "Go not found, installing version $GO_VERSION..."
    wget https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
    rm go$GO_VERSION.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
else
    echo "Go is already installed."
fi
# Set Go environment variables
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
mkdir -p $GOPATH/src/github.com/ethermint
mkdir -p $GOPATH/bin
# Clone Ethermint repository
cd $GOPATH/src/github.com/ethermint
if [ ! -d "ethermint" ]; then
    echo "Cloning Ethermint repository..."
    git clone   

Install Ethermint
make install

ethermintcli config keyring-backend test

# Set up config for CLI
ethermintcli config chain-id $CHAINID
ethermintcli config output json
ethermintcli config indent true
ethermintcli config trust-node true

# if $KEY exists it should be deleted
ethermintcli keys add $KEY --algo "eth_secp256k1"

# Set moniker and chain-id for Ethermint (Moniker can be anything, chain-id must be an integer)
ethermintd init $MONIKER --chain-id $CHAINID

# Allocate genesis accounts (cosmos formatted addresses)
ethermintd add-genesis-account $(ethermintcli keys show $KEY -a) 1000000000000000000photon,1000000000000000000stake

# Sign genesis transaction
ethermintd gentx --name $KEY --keyring-backend test

# Collect genesis tx
ethermintd collect-gentxs

# Enable faucet
cat  $HOME/.ethermintd/config/genesis.json | jq '.app_state["faucet"]["enable_faucet"]=true' >  $HOME/.ethermintd/config/tmp_genesis.json && mv $HOME/.ethermintd/config/tmp_genesis.json $HOME/.ethermintd/config/genesis.json

echo -e '\n\ntestnet faucet enabled'
echo -e 'to transfer tokens to your account address use:'
echo -e "ethermintcli tx faucet request 100photon --from $KEY\n"


# Run this to ensure everything worked and that the genesis file is setup correctly
ethermintd validate-genesis

# Command to run the rest server in a different terminal/window
echo -e '\nrun the following command in a different terminal/window to run the REST server and JSON-RPC:'
echo -e "ethermintcli rest-server --laddr \"tcp://localhost:8545\" --unlock-key $KEY --chain-id $CHAINID --trace\n"

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
ethermintd start --pruning=nothing --rpc.unsafe --log_level "main:info,state:info,mempool:info" --trace
