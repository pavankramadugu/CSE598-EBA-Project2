# Setup Documentation: Supply Chain Smart Contract

This documentation outlines the steps required to set up and run the Supply Chain Smart Contract application developed in Go. This application utilizes Hyperledger Fabric's Contract API to manage products in a supply chain scenario.

## Prerequisites

Before proceeding with the setup, ensure that you have the following prerequisites installed on your system:

- Go (version 1.21.4 or later)
- Git (for cloning the repository)

## Installation Steps

### 1. Navigate to the Project Directory

After cloning the repository, navigate to the project directory:

```sh
cd CSE598-EBA-Project2
```

### 2. Install Dependencies

The project requires several Go modules as dependencies. Install them by running:

```sh
go mod tidy
```

This command will download and install the necessary dependencies specified in the `go.mod` file.

### 3. Vendor Dependencies

To ensure that all dependencies are available for the Hyperledger Fabric chaincode, use the `go mod vendor` command:

```sh
go mod vendor
```
This command creates a `vendor` directory in your project, containing all the dependencies. This is necessary for Hyperledger Fabric to package the chaincode with all its dependencies.

### 4. Test the Chaincode

```sh
go test -v
```

This command runs the test files in the directory. It will output the results of the tests, including any failures or errors.


## Deployment Steps

### 1. Navigate to Fabric Samples Test Network

Navigate to the Fabric samples test network directory, which is part of the Hyperledger Fabric installation:

```sh
cd path/to/fabric-samples/test-network
```

Replace `path/to/fabric-samples` with the actual path to your Fabric samples directory.

### 2. Copy Deployment Script

Copy the deployment script `deploy_chaincode.sh` from your project directory to the Fabric samples test network directory:

```sh
cp path/to/CSE598-EBA-Project2/deploy_chaincode.sh .
```

Replace `path/to/CSE598-EBA-Project2` with the actual path to your project directory.

### 3. Execute Deployment Script

Give execute permissions to the deployment script and run it:

Run the deployment script with the path to the Go smart contract directory as an argument, <path-to-code> should be replaced with the actual directory path

```sh
chmod +x deploy_chaincode.sh
./deploy_chaincode.sh <path-to-code>
```

This script will deploy your chaincode to the Hyperledger Fabric network. Make sure to copy and enter the package ID for each organization when prompted.

## Usage

After successful deployment, you can interact with the smart contract using the Fabric network CLI commands mentioned in the setup document.
