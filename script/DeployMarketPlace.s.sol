//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;
import {Script} from "forge-std/Script.sol";
import {NFTHolderContract} from "../src/NFTHolderContract.sol";
import {TestNFT} from "../src/TestNFT.sol";
import {MarketPlace} from "../src/MarketPlace.sol";

contract DeployMarketPlace is Script {
    function run() external returns (NFTHolderContract, TestNFT, MarketPlace) {
        uint256 privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.startBroadcast(privateKey);
        NFTHolderContract nftContractHolder = new NFTHolderContract();
        TestNFT testNft = new TestNFT();
        // TODO: add wrappedEthAddress
        MarketPlace marketPlace = new MarketPlace(
            address(nftContractHolder),
            address(0)
        );
        nftContractHolder.transferOwnership(address(marketPlace));
        vm.stopBroadcast();

        return (nftContractHolder, testNft, marketPlace);
    }
}
