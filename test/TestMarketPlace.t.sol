//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;
import {Test} from "forge-std/Test.sol";
import {NFTHolderContract} from "../src/NFTHolderContract.sol";
import {TestNFT} from "../src/TestNFT.sol";
import {DeployMarketPlace} from "../script/DeployMarketPlace.s.sol";
import {MarketPlace} from "../src/MarketPlace.sol";
import {IERC721} from "@openzeppelin/token/ERC721/IERC721.sol";

contract TestMarketPlace is Test {
    TestNFT testNft;
    NFTHolderContract nftHolder;
    MarketPlace marketPlace;
    address minterAddress;
    function setUp() external {
        DeployMarketPlace deployMarketPlace = new DeployMarketPlace();
        (nftHolder, testNft, marketPlace) = deployMarketPlace.run();
        minterAddress = makeAddr("minterAddress");
        vm.startPrank(minterAddress);
        testNft.mintNFt();
    }

    function testListNft() public {
        vm.startPrank(minterAddress);
        IERC721(address(testNft)).approve(address(marketPlace), 1);
        marketPlace.listNFT(address(testNft), 1, 10 ether);
        uint256 listedNft = marketPlace.getUserListedNfts(minterAddress).length;
        assertEq(listedNft, 1);
        vm.stopPrank();
    }

    function testUnlist() public {
        vm.startPrank(minterAddress);
        testNft.mintNFt();
        IERC721(address(testNft)).approve(address(marketPlace), 1);
        IERC721(address(testNft)).approve(address(marketPlace), 2);
        marketPlace.listNFT(address(testNft), 1, 10 ether);
        marketPlace.listNFT(address(testNft), 2, 10 ether);
        marketPlace.unListNft(address(testNft), 1);
        uint256 listedNft = marketPlace.getUserListedNfts(minterAddress).length;
        assertEq(listedNft, 1);
        vm.stopPrank();
    }
}
