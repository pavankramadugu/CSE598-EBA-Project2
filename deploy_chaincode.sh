#!/bin/bash -e

# Check if the path to the smart contract code is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path-to-code>"
    echo "<path-to-code> is the directory containing the Go smart contract code after running 'go mod tidy' and 'go mod vendor'"
    exit 1
fi

# Set the path to the smart contract code
SMART_CONTRACT_PATH="$1"

# Log file
LOG_FILE="deployment_log.txt"

# Function to log a message
log() {
    echo "$(date): $1" | tee -a "$LOG_FILE"
}

# Bring up a fresh test network
log "Bringing up a fresh test network..."
./network.sh down && ./network.sh up

# Check running Docker containers
log "Checking running Docker containers..."
docker ps -a | grep "hyperledger/fabric" | tee -a "$LOG_FILE"

# Create a channel and have the two example orgs join it
log "Creating a channel and having the two example orgs join it..."
./network.sh createChannel | tee -a "$LOG_FILE"

# Set environment variables
log "Setting environment variables..."
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true

# Package the smart contract
log "Packaging the smart contract..."
peer lifecycle chaincode package supplyChain.tar.gz --path "$SMART_CONTRACT_PATH" --lang golang --label supplyChain 2>&1 | tee -a "$LOG_FILE"

# Check if the package has been created
log "Checking if the package has been created..."
ls | grep supplyChain.tar.gz | tee -a "$LOG_FILE"

# Install the chaincode package on Org1
log "Installing the chaincode package on Org1..."
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
peer lifecycle chaincode install supplyChain.tar.gz 2>&1 | tee -a "$LOG_FILE"

# Install the chaincode package on Org2
log "Installing the chaincode package on Org2..."
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer lifecycle chaincode install supplyChain.tar.gz 2>&1 | tee -a "$LOG_FILE"

# Approve the chaincode for Org1
log "Approving the chaincode for Org1..."
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
peer lifecycle chaincode queryinstalled 2>&1 | tee -a "$LOG_FILE"
read -p "Enter Package ID for Org1: " CC_PACKAGE_ID_ORG1
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name supplyChain --version 1.0 --package-id $CC_PACKAGE_ID_ORG1 --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 2>&1 | tee -a "$LOG_FILE"

# Approve the chaincode for Org2
log "Approving the chaincode for Org2..."
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer lifecycle chaincode queryinstalled 2>&1 | tee -a "$LOG_FILE"
read -p "Enter Package ID for Org2: " CC_PACKAGE_ID_ORG2
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name supplyChain --version 1.0 --package-id $CC_PACKAGE_ID_ORG2 --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 2>&1 | tee -a "$LOG_FILE"

# Check if the chaincode is ready to be committed
log "Checking if the chaincode is ready to be committed..."
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name supplyChain --version 1.0 --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json 2>&1 | tee -a "$LOG_FILE"

# Commit the chaincode to the channel
log "Committing the chaincode to the channel..."
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name supplyChain --version 1.0 --sequence 1 --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt 2>&1 | tee -a "$LOG_FILE"

# Check if the chaincode is committed
log "Checking if the chaincode committed to the channel..."
peer lifecycle chaincode querycommitted --channelID mychannel --name supplyChain --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem 2>&1 | tee -a "$LOG_FILE"

# Invoke the initLedger function
log "Invoking the initLedger function..."
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n supplyChain --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"initLedger","Args":[]}' 2>&1 | tee -a "$LOG_FILE"

# Get All Products from the Ledger
log "Calling the GetAllProducts function..."
peer chaincode query -C mychannel -n supplyChain -c '{"Args":["GetAllProducts"]}' 2>&1 | tee -a "$LOG_FILE"