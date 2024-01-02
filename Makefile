# ================================================================
# │                 GENERIC MAKEFILE CONFIGURATION               │
# ================================================================
-include .env

.PHONY: all test clean help install snapshot format anvil

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...] [VERIFY=...]\n    example: make deploy NETWORK_ARGS=\"--network holesky\" VERIFY=true"

clean 		:; forge clean
remove 		:; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"
update 		:; forge update
build 		:; forge build
test 		:; forge test 
snapshot 	:; forge snapshot
format 		:; forge fmt

# Configure Anvil
anvil 				:; anvil -m 'test test test test test test test test test test test junk' --steps-tracing #--block-time 1
DEFAULT_ANVIL_KEY 	:= 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
NETWORK_ARGS 		:= --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

# Check if the --network holesky flag is present
ifeq ($(findstring --network holesky,$(ARGS)),--network holesky)
	NETWORK_ARGS := --rpc-url $(HOLESKY_RPC_URL) --private-key $(HOLESKY_PRIVATE_KEY) --broadcast
endif

## TODO: Add mainnet network flag here


## Etherscan Verification Flags
ifeq ($(VERIFY),true)
	VERIFICATION_FLAGS := --verify --etherscan-api-key $(ETHERSCAN_API_KEY)
endif


# ================================================================
# │                CONTRACT SPECIFIC CONFIGURATION               │
# ================================================================
install:
	forge install foundry-rs/forge-std@v1.5.3 --no-commit && \
	forge install Cyfrin/foundry-devops@0.0.11 --no-commit && \
	forge install openzeppelin/openzeppelin-contracts@v4.8.3 --no-commit && \
	forge install forge install transmissions11/solmate@v6 --no-commit
	

.PHONY: deploy fund withdraw
deploy:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS) $(VERIFICATION_FLAGS) -vvvv

fund:
	@forge script script/InteractionsFundMe.s.sol:FundFundMe $(NETWORK_ARGS)

withdraw:
	@forge script script/InteractionsFundMe.s.sol:WithdrawFundMe $(NETWORK_ARGS)