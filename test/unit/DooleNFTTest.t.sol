//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {DeployDoodlePepe} from "../../script/DeployDoodlePepe.s.sol";
import {DoodlePepeNft} from "../../src/DoodlePepe.sol";

contract DoodleNFTTest is Test {
    DoodlePepeNft doodlePepeNft;
    address minter;
    string[4] _nftsURIs = [
        "https://crimson-main-lark-874.mypinata.cloud/ipfs/QmPtECc7vZpDL6mXxiXAFH721fbQF4zm63pBZeNfmSGyGg",
        "https://crimson-main-lark-874.mypinata.cloud/ipfs/QmYMvsra3WprQ6hxTm3rBcfYuR71G3m7YeXBsu5h3eas7V",
        "https://crimson-main-lark-874.mypinata.cloud/ipfs/QmbwbE8LZuW9eSKZwD3gGKWzq4E8TBHUkidnP9v999bxEX",
        "https://crimson-main-lark-874.mypinata.cloud/ipfs/Qmb14x7iKJZn1ZqCKkuYYK6wa6j88ZyhWZbgMKoXPm79sW"
    ];

    function setUp() external {
        DeployDoodlePepe deployDoodlePepe = new DeployDoodlePepe();
        doodlePepeNft = deployDoodlePepe.run();
        minter = makeAddr("Minter");
    }

    function testMintNFT(uint256 index) public {
        index = bound(index, 0, 3);
        vm.startPrank(minter);
        doodlePepeNft.mintNft(index);
        uint256 balanceOf = doodlePepeNft.balanceOf(minter);
        vm.assertEq(balanceOf, 1);
        vm.stopPrank();
    }

    function testOutOfIndex(uint256 index) public {
        index = bound(index, 4, type(uint96).max);
        vm.startPrank(minter);
        vm.expectRevert(DoodlePepeNft.DoodlePepeNft__OutOfIndex.selector);
        doodlePepeNft.mintNft(index);
    }

    function testURIs(uint256 index) public view {
        index = bound(index, 0, 3);
        string[4] memory tokenURIs = doodlePepeNft.getTokenUris();
        bytes32 value = keccak256(abi.encodePacked(tokenURIs[index]));
        bytes32 expected = keccak256(abi.encodePacked(_nftsURIs[index]));
        vm.assertEq(value, expected);
    }

    modifier expressMint() {
        for (uint256 i = 0; i < 3; i++) {
            vm.prank(minter);
            doodlePepeNft.mintNft(i);
        }
        _;
    }

    function testMaxMint() public expressMint {
        vm.startPrank(minter);
        doodlePepeNft.mintNft(1);
        doodlePepeNft.mintNft(3);
        vm.expectRevert(DoodlePepeNft.DoodlePepeNft__AddressMintedMaxNFT.selector);
        doodlePepeNft.mintNft(1);
        vm.stopPrank();
    }
}
