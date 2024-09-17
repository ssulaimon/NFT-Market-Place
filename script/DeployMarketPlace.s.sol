//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {NFTHolderContract} from "../src/NFTHolderContract.sol";
import {MarketPlaceNFT} from "../src/MarketPlaceNFT.sol";
import {MarketPlace} from "../src/MarketPlace.sol";
import {WrappedEth} from "../src/WrappedEthFucet.sol";
import{DoodlePepeNft} from "../src/DoodlePepe.sol";
//0x06a3FdF49c54952F7a9bc4d44186434DF370b881 NFT Market Place
//0x85eB8e8D737744649602378f8545Be5F45560712 WETH Fucet
//0xfDBDb5d12dEb685B4dAB98D1d7698b52c4545480 NFT Holder Contract

contract DeployMarketPlace is Script {
    function _getDeployerKey() private view returns (uint256) {
        if (block.chainid == 31337) {
            return 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        } else {
            return vm.envUint("EVM_PRIVATE_KEY");
        }
    }

    function run() external returns (NFTHolderContract, MarketPlace, WrappedEth, uint256) {
        uint256 privateKey = _getDeployerKey();

        vm.startBroadcast();
        NFTHolderContract nftContractHolder = new NFTHolderContract();
        // MarketPlaceNFT testNft = new MarketPlaceNFT();
        WrappedEth wrappedEth = new WrappedEth();
        MarketPlace marketPlace = new MarketPlace(address(nftContractHolder), address(wrappedEth));
        nftContractHolder.transferOwnership(address(marketPlace));
        vm.stopBroadcast();

        return (nftContractHolder, marketPlace, wrappedEth, privateKey);
    }
}
// contract DeployNFT is Script{
//      function run() external returns (DoodlePepeNft) {
//         string[4] memory _nftsURIs = [
//             "https://crimson-main-lark-874.mypinata.cloud/ipfs/QmPtECc7vZpDL6mXxiXAFH721fbQF4zm63pBZeNfmSGyGg",
//             "https://crimson-main-lark-874.mypinata.cloud/ipfs/QmYMvsra3WprQ6hxTm3rBcfYuR71G3m7YeXBsu5h3eas7V",
//             "https://crimson-main-lark-874.mypinata.cloud/ipfs/QmbwbE8LZuW9eSKZwD3gGKWzq4E8TBHUkidnP9v999bxEX",
//             "https://crimson-main-lark-874.mypinata.cloud/ipfs/Qmb14x7iKJZn1ZqCKkuYYK6wa6j88ZyhWZbgMKoXPm79sW"
//         ];
//         vm.startBroadcast();
//         DoodlePepeNft nftContract = new DoodlePepeNft(_nftsURIs);
//         vm.stopBroadcast();
//         return nftContract;
//     }
// }
