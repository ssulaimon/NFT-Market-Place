//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {DeployFucet} from "../../script/DeployWrappedEthFucet.s.sol";
import {WrappedEth} from "../../src/WrappedEthFucet.sol";

contract WrappedEthTest is Test {
    WrappedEth wrappedEth;
    address minter;

    function setUp() external {
        DeployFucet deployFucet = new DeployFucet();
        wrappedEth = WrappedEth(deployFucet.run());
        minter = makeAddr("minter");
    }

    function testRequestEther() public {
        vm.prank(minter);
        wrappedEth.mint();
        uint256 balanceOf = wrappedEth.balanceOf(minter);
        vm.assertEq(balanceOf, 1 ether);
    }

    function testMintRevert() public {
        vm.startPrank(minter);
        wrappedEth.mint();
        vm.expectRevert(WrappedEth.WrappedEth__MintFail.selector);
        wrappedEth.mint();
        vm.stopPrank();
    }

    function testMintNew() public {
        vm.warp(3);
        vm.startPrank(minter);
        wrappedEth.mint();
        vm.warp(block.timestamp + 2 days);
        wrappedEth.mint();
        uint256 balanceOf = wrappedEth.balanceOf(minter);
        vm.assertEq(balanceOf, 2 ether);
        vm.stopPrank();
    }
}
