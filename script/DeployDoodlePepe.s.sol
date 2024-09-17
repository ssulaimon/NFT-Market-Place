//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {DoodlePepeNft} from "../src/DoodlePepe.sol";

contract DeployDoodlePepe is Script {
    function run() external returns (DoodlePepeNft) {
        string[4] memory _nftsURIs = [
            "https://crimson-main-lark-874.mypinata.cloud/ipfs/QmPtECc7vZpDL6mXxiXAFH721fbQF4zm63pBZeNfmSGyGg",
            "https://crimson-main-lark-874.mypinata.cloud/ipfs/QmYMvsra3WprQ6hxTm3rBcfYuR71G3m7YeXBsu5h3eas7V",
            "https://crimson-main-lark-874.mypinata.cloud/ipfs/QmbwbE8LZuW9eSKZwD3gGKWzq4E8TBHUkidnP9v999bxEX",
            "https://crimson-main-lark-874.mypinata.cloud/ipfs/Qmb14x7iKJZn1ZqCKkuYYK6wa6j88ZyhWZbgMKoXPm79sW"
        ];
        vm.startBroadcast();
        DoodlePepeNft nftContract = new DoodlePepeNft(_nftsURIs);
        vm.stopBroadcast();
        return nftContract;
    }
}
