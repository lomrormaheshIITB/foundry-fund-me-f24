-include .env

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Targets
.PHONY: all build deploy-sepolia fork-test-mainnet fork-test-sepolia test format layout coverage anvil clean remove install update snapshot deploy fund withdraw help

# Default target
all: clean build test

# Build the smart contracts
build:
	@echo "Compiling the contracts..."
	forge build

# Run test on a fork of the Sepolia testnet
fork-test-sepolia:
	@echo "Running test on a forked Sepolia testnet blockchain..."
	forge test --fork-url $(SEPOLIA_RPC_URL)

# Run test on a fork of the Mainnet
fork-test-mainnet:
	@echo "Running test on a forked Mainnet blockchain..."
	forge test --fork-url $(MAINNET_RPC_URL)

# Run the unit test
test:
	@echo "Running tests..."
	forge test

# format code
format:
	@echo "Formating code..."
	forge fmt

# Check smart contract layout
layout:
	@echo "Inspecting FundMe layout..."
	forge inspect FundMe storageLayout

# Check coverge
coverage:
	@echo "Running coverage..."
	forge coverage

# Anvil (local blockchain) start
anvil:
	@echo "Starting local Anvil blockchain..."
	anvil -b 15

# Clean the build artifacts
clean:
	@echo "Cleaning the project..."
	forge clean

# Remove modules
remove:
	@echo "Removing modules..."
	rm -rf .gitmodules
	rm -rf .git/modules/*
	rm -rf lib
	touch .gitmodules
	git commit -m "modules" 

# install dependencies
install:
	@echo "Installing dependencies..."
	forge install Cyfrin/foundry-devops --no-commit
	forge install smartcontractkit/chainlink-brownie-contracts@1.2.0 --no-commit

# Update dependencies
update:
	forge update

# Create gas snapshot
snapshot:
	@echo "Creating a gas snapshot of smart contract..."
	forge snapshot

# Deploy smart contract with NETWORK_ARGS input
deploy:
	@echo "Deploying smart contract..."
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

# NETWORK ARG
NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia, $(ARGS)), --network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verfiy --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

# Deploying a smart contract (customized based onn deploy script)
deploy-sepolia:
	@echo "Deploying the FundMe contract..."
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

# For deploying Interactions.s.sol:FundFundMe as well as for Interactions.s.sol:WithdrawFundMe we have to include a sender's address `--sender <ADDRESS>` 
SENDER_ADDRESS := <sender's address>

# Fund the smart contract
fund:
	@echo "Funding the smart contract..."
	@forge script script/Interactions.s.sol:FundFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

# Withdraw from smart contract
withdraw:
	@echo "Withdrawing from the smart contract..."
	@forge script script/Interactions.s.sol:WithdrawFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

help:
	@echo "Usage:"
	@echo " make deploy [ARGS=...]\n	example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo " make fund [ARGS=...]\n	example: make fund ARGS=\"--network sepolia\""