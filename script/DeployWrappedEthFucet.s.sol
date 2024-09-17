//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {Script} from "forge-std/Script.sol";
import {WrappedEth} from "../src/WrappedEthFucet.sol";

contract DeployFucet is Script {
    function run() external returns (address) {
        vm.startBroadcast();
        WrappedEth wrappedEth = new WrappedEth();
        vm.stopBroadcast();
        return address(wrappedEth);
    }
}
