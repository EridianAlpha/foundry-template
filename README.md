# Foundry Template Files

- [1. Overview](#1-overview)
- [2. Clone repository](#2-clone-repository)
  - [2.1. Install Dependencies](#21-install-dependencies)
  - [2.2. Create the `.env` file](#22-create-the-env-file)
- [3. Testing](#3-testing)
  - [3.1. Tests (Fork)](#31-tests-fork)
  - [3.2. Coverage (Fork)](#32-coverage-fork)
- [4. Deployment](#4-deployment)
- [5. Interactions](#5-interactions)
  - [5.1. Force Send ETH](#51-force-send-eth)
- [6. License](#6-license)

## 1. Overview

This repo contains template files for a new Foundry project.

This is not a Foundry project but contains the files that can be copied into a new project after running `forge init`.

Think of the example spaceship created by Hactar for Krikkit in the Hitchhiker's Guide to the Galaxy - Life, the Universe, and Everything. This is the model ship, not a working ship itself 🚀🏏

## 2. Clone repository

```bash
git clone https://github.com/EridianAlpha/foundry-template.git
```

### 2.1. Install Dependencies

This should happen automatically when first running a command, but the installation can be manually triggered with the following commands:

```bash
git submodule init
git submodule update
make install
```

### 2.2. Create the `.env` file

Use the `.env.example` file as a template to create a `.env` file.

## 3. Testing

### 3.1. Tests (Fork)

```bash
make test
make test-v
make test-summary
```

### 3.2. Coverage (Fork)

```bash
make coverage
make coverage-report
```

## 4. Deployment

Deploys SimpleSwap and all modules to the Anvil chain specified in the `.env` file.

| Chain        | Command                    |
| ------------ | -------------------------- |
| Anvil        | `make deploy anvil`        |
| Holesky      | `make deploy holesky`      |
| Base Sepolia | `make deploy base-sepolia` |
| Base Mainnet | `make deploy base-mainnet` |

## 5. Interactions

Interactions are defined in `./script/Interactions.s.sol`

If `DEPLOYED_CONTRACT_ADDRESS` is set in the `.env` file, that contract address will be used for interactions.
If that variable is not set, the latest deployment on the specified chain will be used.

### 5.1. Force Send ETH

Send ETH to the contract using a intermediate selfdestruct contract.
This does not call the `receive` function on the contract.
Input value in ETH e.g. `0.15`.

| Chain        | Command                          |
| ------------ | -------------------------------- |
| Anvil        | `make forceSendEth anvil`        |
| Holesky      | `make forceSendEth holesky`      |
| Base Sepolia | `make forceSendEth base-sepolia` |
| Base Mainnet | `make forceSendEth base-mainnet` |

## 6. License

[MIT](https://choosealicense.com/licenses/mit/)
