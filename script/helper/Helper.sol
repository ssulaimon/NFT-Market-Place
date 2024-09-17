//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/mocks/token/ERC20Mock.sol";

contract Helper is Script {
    address public wethAddress;

    constructor() {
        if (block.chainid == 115511) {
            wethAddress = sepoliaWethAddress();
        } else {
            wethAddress = anvilWethAddress();
        }
    }

    function sepoliaWethAddress() public pure returns (address) {
        // TODO: add WETH address;
        return address(0);
    }

    function anvilWethAddress() public returns (address) {
        if (wethAddress != address(0)) {
            return wethAddress;
        } else {
            vm.startBroadcast();
            ERC20Mock mockToken = new ERC20Mock();
            vm.stopBroadcast();
            return address(mockToken);
        }
    }
}
