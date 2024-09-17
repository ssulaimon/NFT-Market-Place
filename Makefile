-include .env

build:
	forge build
# forge deploy:
# 	forge script script/DeployDoodlePepe.s.sol --private-key $(EVM_PRIVATE_KEY) --rpc-url $(RPC_URL) --broadcast --verify --etherscan-api-key $(ETHER_SCAN) --legacy -vvvvv

deploy market:
	forge script script/DeployMarketPlace.s.sol:DeployMarketPlace --private-key $(EVM_PRIVATE_KEY) --rpc-url $(RPC_URL) --broadcast --verify --etherscan-api-key $(ETHER_SCAN) --legacy -vvvv

# deploy wrappedETH:
# 	forge script script/DeployWrappedEthFucet.sol --private-key $(EVM_PRIVATE_KEY) --rpc-url $(RPC_URL) --broadcast --verify --etherscan-api-key $(ETHER_SCAN) --legacy -vvvv
	