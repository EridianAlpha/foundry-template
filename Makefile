# ================================================================
# │                 GENERIC MAKEFILE CONFIGURATION               │
# ================================================================
-include .env

.PHONY: test clean help install snapshot format anvil ethernal

help:
	@echo "Usage:"
	@echo "  make deploy-anvil\n

clean 		:; forge clean
update 		:; forge update
build 		:; forge build
test 		:; forge test
snapshot 	:; forge snapshot
format 		:; forge fmt

# Configure Anvil
anvil 		:; anvil -m 'test test test test test test test test test test test junk' --steps-tracing  #--block-time 1

# Configure Network Variables
anvil-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url http://localhost:8545 \
						--private-key $(DEFAULT_ANVIL_KEY) \
	)

holesky-network: 
	$(eval \
		NETWORK_ARGS := --broadcast \
			--rpc-url $(HOLESKY_RPC_URL) \
			--private-key $(HOLESKY_PRIVATE_KEY) \
			--verify \
			--etherscan-api-key $(ETHERSCAN_API_KEY) \
	)

# mainnet-network: 
# 	$(eval \
# 		NETWORK_ARGS := --broadcast \
# 			--rpc-url $(MAINNET_RPC_URL) \
# 			--private-key $(MAINNET_PRIVATE_KEY) \
# 			--verify \
# 			--etherscan-api-key $(ETHERSCAN_API_KEY) \
# 	)


# ================================================================
# │            ETHERNAL BLOCK EXPLORER CONFIGURATION             │
# ================================================================
# https://app.tryethernal.com
ethernal:
	ETHERNAL_API_TOKEN=${ETHERNAL_API_TOKEN} ethernal listen --astUpload true


# ================================================================
# │                   FORK TESTING AND COVERAGE                   │
# ================================================================
test-fork-mainnet:; forge test --fork-url ${MAINNET_RPC_URL}
test-fork-mainnet-v:; forge test --fork-url ${MAINNET_RPC_URL} -vvvv
test-fork-mainnet-summary:; forge test --fork-url ${MAINNET_RPC_URL} --summary

coverage:
	@forge coverage --fork-url ${MAINNET_RPC_URL} --report lcov --report summary
	@echo

coverage-report:
	@forge coverage --fork-url ${MAINNET_RPC_URL} --report debug > coverage-report.txt
	@echo Output saved to coverage-report.txt


# ================================================================
# │                CONTRACT SPECIFIC CONFIGURATION               │
# ================================================================
install:
	forge install foundry-rs/forge-std@v1.7.6 --no-commit && \
	forge install Cyfrin/foundry-devops@0.1.0 --no-commit && \
	forge install openzeppelin/openzeppelin-contracts@v5.0.1 --no-commit && \
	forge install openzeppelin/openzeppelin-contracts-upgradeable@v5.0.1 --no-commit && \
	forge install uniswap/v3-core --no-commit && \
	forge install uniswap/v3-periphery --no-commit \

deploy:
	@forge script script/DeployBasicNft.s.sol:DeployBasicNft $(NETWORK_ARGS) -vvvv

mint-basicNft: 
	@forge script script/Interactions.s.sol:MintBasicNft $(NETWORK_ARGS) -vvvv


# ================================================================
# │                         RUN COMMANDS                         │
# ================================================================
deploy-anvil: anvil-network deploy
deploy-holesky: holesky-network deploy
# deploy-mainnet: mainnet-network deploy

anvil-mint-basicNft: anvil-network mint-basicNft
holesky-mint-basicNft: holesky-network mint-basicNft
# mainnet-mint-basicNft: mainnet-network mint-basicNft