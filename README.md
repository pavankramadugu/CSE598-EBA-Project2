# Setup Documentation for Go Application: Supply Chain Smart Contract

This documentation outlines the steps required to set up and run the Supply Chain Smart Contract application developed in Go. This application utilizes Hyperledger Fabric's Contract API to manage products in a supply chain scenario.

## Prerequisites

Before proceeding with the setup, ensure that you have the following prerequisites installed on your system:

- Go (version 1.21.4 or later)
- Hyperledger Fabric (refer to the official Hyperledger Fabric documentation for installation instructions)
- Git (for cloning the repository)

## Installation Steps

### 1. Navigate to the Project Directory

After cloning the repository, navigate to the project directory:

### 2. Install Dependencies

The project requires several Go modules as dependencies. Install them by running:

```sh
go mod tidy
```

This command will download and install the necessary dependencies specified in the `go.mod` file.