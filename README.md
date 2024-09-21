## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


### Installing Dependencies

```shell
$ forge install smartcontractkit/chainlink-brownie-contracts@1.2.0 --no-commit
```

### Compile Code

```shell
$ forge compile
```

### Test Commands

```shell
$ forge test
$ forge test -vv
$ forge test -vvv
$ forge test -vvvv
$ forge test --match-test/--mt testPriceFeedVersionIsAccurate
$ forge test --match-test testPriceFeedVersionIsAccurate -vvvv --fork-url $SEPOLIA_RPC_URL
```

### Check Coverage of Testing
```shell
$ forge coverage --fork-url $SEPOLIA_RPC_URL
$ forge coverage
```

### Clean Compilation Cache

```shell
$ forge clean
```

### Task List

-   **Mock**: setUp mock Interface for price feed (detect network config based on environment: anvil (local), sepolia Testnet, eth mainnet)
-   **Deployment**: deploy using script (modular deployment)
-   **Testing**: test the smart contract (modular testing)
-   **Prank**: prank user for testing (only supported in foundry)


### Tools

-   **Remix**:
-   **MetaMask**: wallet (extension on web browser)
-   **faucet**: add balance to sepolia test accounts created on MetaMask Wallet
-   **foundry**:
-   **alchemy**:
-   **Git**: Version Control
-   

### ToDo List
-   **How to sign a Transaction**
-   