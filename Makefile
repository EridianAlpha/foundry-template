# ================================================================
# │                 GENERIC MAKEFILE CONFIGURATION               │
# ================================================================
-include .env

.PHONY: test

help:
	@echo "Usage:"
	@echo "  make deploy anvil\n

# ================================================================
# │                      NETWORK CONFIGURATION                   │
# ================================================================
get-network-args: $(word 2, $(MAKECMDGOALS))-network

anvil: # Added to stop error output when running commands e.g. make deploy anvil
	@echo
anvil-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${ANVIL_RPC_URL} \
						--private-key ${ANVIL_PRIVATE_KEY} \
	)

holesky: # Added to stop error output when running commands e.g. make deploy holesky
	@echo
holesky-network:
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${HOLESKY_RPC_URL} \
						--private-key ${HOLESKY_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${ETHERSCAN_API_KEY} \
	)

base-sepolia: # Added to stop error output when running commands e.g. make deploy base-sepolia
	@echo
base-sepolia-network: 
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${BASE_SEPOLIA_RPC_URL} \
						--private-key ${BASE_SEPOLIA_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${BASESCAN_API_KEY} \
	)

base-mainnet: # Added to stop error output when running commands e.g. make deploy base-mainnet
	@echo
base-mainnet-network: 
	$(eval \
		NETWORK_ARGS := --broadcast \
						--rpc-url ${BASE_MAINNET_RPC_URL} \
						--private-key ${BASE_MAINNET_PRIVATE_KEY} \
						--verify \
						--etherscan-api-key ${BASESCAN_API_KEY} \
	)

# ================================================================
# │                      TESTING AND COVERAGE                    │
# ================================================================
test:; forge test --fork-url ${FORK_RPC_URL}
test-v:; forge test --fork-url ${FORK_RPC_URL} -vvvv
test-summary:; forge test --fork-url ${FORK_RPC_URL} --summary

coverage:
	@forge coverage --fork-url ${FORK_RPC_URL} --report summary --report lcov 
	@echo

coverage-report:
	@forge coverage --fork-url ${FORK_RPC_URL} --report debug > coverage-report.txt
	@echo Output saved to coverage-report.txt

# ================================================================
# │                   USER INPUT - ASK FOR VALUE                 │
# ================================================================
ask-for-value:
	@echo "Enter value: "
	@read value; \
	echo $$value > MAKE_CLI_INPUT_VALUE.tmp;

# If multiple values are passed (comma separated), convert the first value to wei
convert-value-to-wei:
	@value=$$(cat MAKE_CLI_INPUT_VALUE.tmp); \
	first_value=$$(echo $$value | cut -d',' -f1); \
	remaining_inputs=$$(echo $$value | cut -d',' -f2-); \
	if [ "$$first_value" = "$$value" ]; then \
		remaining_inputs=""; \
	fi; \
 	wei_value=$$(echo "$$first_value * 10^18 / 1" | bc); \
	if [ -n "$$remaining_inputs" ]; then \
		final_value=$$wei_value,$$remaining_inputs; \
	else \
		final_value=$$wei_value; \
	fi; \
 	echo $$final_value > MAKE_CLI_INPUT_VALUE.tmp;

# If multiple values are passed (comma separated), convert the first value to USDC
convert-value-to-USDC:
	@value=$$(cat MAKE_CLI_INPUT_VALUE.tmp); \
	first_value=$$(echo $$value | cut -d',' -f1); \
	remaining_inputs=$$(echo $$value | cut -d',' -f2-); \
	if [ "$$first_value" = "$$value" ]; then \
		remaining_inputs=""; \
	fi; \
 	usdc_value=$$(echo "$$first_value * 10^6 / 1" | bc); \
	if [ -n "$$remaining_inputs" ]; then \
		final_value=$$usdc_value,$$remaining_inputs; \
	else \
		final_value=$$usdc_value; \
	fi; \
 	echo $$final_value > MAKE_CLI_INPUT_VALUE.tmp;

store-value:
	$(eval \
		MAKE_CLI_INPUT_VALUE := $(shell cat MAKE_CLI_INPUT_VALUE.tmp) \
	)

remove-value:
	@rm -f MAKE_CLI_INPUT_VALUE.tmp

# ================================================================
# │                CONTRACT SPECIFIC CONFIGURATION               │
# ================================================================
install:
	forge install foundry-rs/forge-std@v1.9.2 --no-commit && \
	forge install Cyfrin/foundry-devops@0.2.2 --no-commit && \
	forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit && \
	forge install openzeppelin/openzeppelin-contracts-upgradeable@v5.0.2 --no-commit && \
	forge install uniswap/v3-core --no-commit && \
	forge install uniswap/v3-periphery --no-commit && \
	forge install uniswap/swap-router-contracts --no-commit

# ================================================================
# │                         RUN COMMANDS                         │
# ================================================================
interactions-script = @forge script script/Interactions.s.sol:Interactions ${NETWORK_ARGS} -vvvv

# ================================================================
# │                    RUN COMMANDS - DEPLOYMENT                 │
# ================================================================
deploy-script:; @forge script script/Deploy.s.sol:Deploy --sig "standardDeployment()" ${NETWORK_ARGS} -vvvv
deploy: get-network-args \
	deploy-script

# ================================================================
# │                  RUN COMMANDS - FORCE SEND ETH               │
# ================================================================
forceSendEth-script:; $(interactions-script) --sig "forceSendEth(uint256)" ${MAKE_CLI_INPUT_VALUE}
forceSendEth: get-network-args \
	ask-for-value \
	convert-value-to-wei \
	store-value \
	forceSendEth-script \
	remove-value

# ================================================================
# │                  RUN COMMANDS - SWAP FUNCTIONS               │
# ================================================================
sendEth-script:; $(interactions-script) --sig "sendEth(uint256)" ${MAKE_CLI_INPUT_VALUE}
sendEth: get-network-args \
	ask-for-value \
	convert-value-to-wei \
	store-value \
	sendEth-script \
	remove-value

swapUsdc-script:; $(interactions-script) --sig "swapUsdc(uint256)" ${MAKE_CLI_INPUT_VALUE}
swapUsdc: get-network-args \
	ask-for-value \
	convert-value-to-USDC \
	store-value \
	swapUsdc-script \
	remove-value

# ================================================================
# │                RUN COMMANDS - WITHDRAW FUNCTIONS             │
# ================================================================
withdrawEth-script:; $(interactions-script) --sig "withdrawEth(address)" ${MAKE_CLI_INPUT_VALUE}
withdrawEth: get-network-args \
	ask-for-value \
	store-value \
	withdrawEth-script \
	remove-value

withdrawTokens-script:; $(interactions-script) --sig "withdrawTokens(string, address)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
withdrawTokens: get-network-args \
	ask-for-value \
	store-value \
	withdrawTokens-script \
	remove-value

# ================================================================
# │                    RUN COMMANDS - UPGRADES                   │
# ================================================================
upgrade-script:; $(interactions-script) --sig "upgrade()"
upgrade: get-network-args \
	upgrade-script

# ================================================================
# │                     RUN COMMANDS - UPDATES                   │
# ================================================================
updateContractAddress-script:; $(interactions-script) --sig "updateContractAddress(string, address)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
updateContractAddress: get-network-args \
	ask-for-value \
	store-value \
	updateContractAddress-script \
	remove-value

updateTokenAddress-script:; $(interactions-script) --sig "updateTokenAddress(string, address)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
updateTokenAddress: get-network-args \
	ask-for-value \
	store-value \
	updateTokenAddress-script \
	remove-value

updateUniswapV3PoolAddress-script:; $(interactions-script) --sig "updateUniswapV3PoolAddress(string, address, uint24)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
updateUniswapV3PoolAddress: get-network-args \
	ask-for-value \
	store-value \
	updateUniswapV3PoolAddress-script \
	remove-value

updateSlippageTolerance-script:; $(interactions-script) --sig "updateSlippageTolerance(uint16)" ${MAKE_CLI_INPUT_VALUE}
updateSlippageTolerance: get-network-args \
	ask-for-value \
	store-value \
	updateSlippageTolerance-script \
	remove-value

# ================================================================
# │                  RUN COMMANDS - ROLE MANAGEMENT              │
# ================================================================
grantRole-script:; $(interactions-script) --sig "grantRole(string, address)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
grantRole: get-network-args \
	ask-for-value \
	store-value \
	grantRole-script \
	remove-value

revokeRole-script:; $(interactions-script) --sig "revokeRole(string, address)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
revokeRole: get-network-args \
	ask-for-value \
	store-value \
	revokeRole-script \
	remove-value

getRoleAdmin-script:; $(interactions-script) --sig "getRoleAdmin(string)" ${MAKE_CLI_INPUT_VALUE}
getRoleAdmin: get-network-args \
	ask-for-value \
	store-value \
	getRoleAdmin-script \
	remove-value

getRoleMember-script:; $(interactions-script) --sig "getRoleMember(string, uint256)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
getRoleMember: get-network-args \
	ask-for-value \
	store-value \
	getRoleMember-script \
	remove-value

getRoleMembers-script:; $(interactions-script) --sig "getRoleMembers(string)" ${MAKE_CLI_INPUT_VALUE}
getRoleMembers: get-network-args \
	ask-for-value \
	store-value \
	getRoleMembers-script \
	remove-value

getRoleMemberCount-script:; $(interactions-script) --sig "getRoleMemberCount(string)" ${MAKE_CLI_INPUT_VALUE}
getRoleMemberCount: get-network-args \
	ask-for-value \
	store-value \
	getRoleMemberCount-script \
	remove-value

hasRole-script:; $(interactions-script) --sig "checkRole(string, address)" $(shell echo $(MAKE_CLI_INPUT_VALUE) | tr ',' ' ')
hasRole: get-network-args \
	ask-for-value \
	store-value \
	hasRole-script \
	remove-value

renounceRole-script:; $(interactions-script) --sig "renounceRole(string)" ${MAKE_CLI_INPUT_VALUE}
renounceRole: get-network-args \
	ask-for-value \
	store-value \
	renounceRole-script \
	remove-value

# ================================================================
# │                     RUN COMMANDS - GETTERS                   │
# ================================================================
getCreator-script:; $(interactions-script) --sig "getCreator()"
getCreator: get-network-args \
	getCreator-script

getVersion-script:; $(interactions-script) --sig "getVersion()"
getVersion: get-network-args \
	getVersion-script

getBalance-script:; $(interactions-script) --sig "getBalance(string)" ${MAKE_CLI_INPUT_VALUE}
getBalance: get-network-args \
	ask-for-value \
	store-value \
	getBalance-script \
	remove-value

getEventBlockNumbers-script:; $(interactions-script) --sig "getEventBlockNumbers()"
getEventBlockNumbers: get-network-args \
	getEventBlockNumbers-script

getContractAddress-script:; $(interactions-script) --sig "getContractAddress(string)" ${MAKE_CLI_INPUT_VALUE}
getContractAddress: get-network-args \
	ask-for-value \
	store-value \
	getContractAddress-script \
	remove-value

getTokenAddress-script:; $(interactions-script) --sig "getTokenAddress(string)" ${MAKE_CLI_INPUT_VALUE}
getTokenAddress: get-network-args \
	ask-for-value \
	store-value \
	getTokenAddress-script \
	remove-value

getUniswapV3Pool-script:; $(interactions-script) --sig "getUniswapV3Pool(string)" ${MAKE_CLI_INPUT_VALUE}
getUniswapV3Pool: get-network-args \
	ask-for-value \
	store-value \
	getUniswapV3Pool-script \
	remove-value

getSlippageTolerance-script:; $(interactions-script) --sig "getSlippageTolerance()"
getSlippageTolerance: get-network-args \
	getSlippageTolerance-script

getModuleVersion-script:; $(interactions-script) --sig "getModuleVersion(string)" ${MAKE_CLI_INPUT_VALUE}
getModuleVersion: get-network-args \
	ask-for-value \
	store-value \
	getModuleVersion-script \
	remove-value