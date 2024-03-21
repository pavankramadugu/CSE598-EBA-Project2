package main // Package main, Do not change this line.

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"time"
)

// Product represents the structure for a product entity
type Product struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	Status    string `json:"status"`
	Owner     string `json:"owner"`
	CreatedAt string `json:"created_at"`
	UpdatedAt string `json:"updated_at"`
	Category  string `json:"category"`
}

// SupplyChainContract defines the smart contract structure
type SupplyChainContract struct {
	contractapi.Contract
}

// getTimestamp returns the transaction timestamp as a string
func (s *SupplyChainContract) getTimestamp(ctx contractapi.TransactionContextInterface) (string, error) {
	txTimestamp, err := ctx.GetStub().GetTxTimestamp()
	if err != nil {
		return "", fmt.Errorf("failed to get transaction timestamp: %v", err)
	}
	return time.Unix(txTimestamp.Seconds, int64(txTimestamp.Nanos)).Format(time.RFC3339), nil
}

// InitLedger initializes the ledger with some example products
func (s *SupplyChainContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	timestamp, err := s.getTimestamp(ctx)
	if err != nil {
		return err
	}

	// Initial set of products to populate the ledger
	products := []Product{
		{ID: "p1", Name: "Laptop", Status: "Manufactured", Owner: "CompanyA", CreatedAt: timestamp, UpdatedAt: timestamp, Description: "High-end gaming laptop", Category: "Electronics"},
	}

	for _, product := range products {
		if err := s.putProduct(ctx, &product); err != nil {
			return err
		}
	}

	return nil
}

// CreateProduct creates a new product in the ledger
func (s *SupplyChainContract) CreateProduct(ctx contractapi.TransactionContextInterface, id, name, owner, description, category string) error {
	// Write your implementation here
}

// UpdateProduct allows updating a product's status, owner, description, and category
func (s *SupplyChainContract) UpdateProduct(ctx contractapi.TransactionContextInterface, id string, newStatus string, newOwner string, newDescription string, newCategory string) error {
	// Write your implementation here
}

// TransferOwnership changes the owner of a product
func (s *SupplyChainContract) TransferOwnership(ctx contractapi.TransactionContextInterface, id, newOwner string) error {
	// Write your implementation here
}

// QueryProduct retrieves a single product from the ledger by ID
func (s *SupplyChainContract) QueryProduct(ctx contractapi.TransactionContextInterface, id string) (*Product, error) {
	// Write your implementation here
}

// putProduct is a helper method for inserting or updating a product in the ledger
func (s *SupplyChainContract) putProduct(ctx contractapi.TransactionContextInterface, product *Product) error {
	productJSON, err := json.Marshal(product)
	if err != nil {
		return err
	}
	return ctx.GetStub().PutState(product.ID, productJSON)
}

// ProductExists is a helper method to check if a product exists in the ledger
func (s *SupplyChainContract) ProductExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
	productJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}
	return productJSON != nil, nil
}

// GetAllProducts is a helper method to retrieve all products from the ledger
func (s *SupplyChainContract) GetAllProducts(ctx contractapi.TransactionContextInterface) ([]*Product, error) {
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var products []*Product
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var product Product
		if err := json.Unmarshal(queryResponse.Value, &product); err != nil {
			return nil, err
		}
		products = append(products, &product)
	}

	return products, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(&SupplyChainContract{})
	if err != nil {
		fmt.Printf("Error creating supply chain chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting supply chain chaincode: %s", err.Error())
	}
}
