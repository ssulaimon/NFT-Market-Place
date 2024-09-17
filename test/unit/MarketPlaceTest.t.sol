//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {DeployMarketPlace} from "../../script/DeployMarketPlace.s.sol";
import {NFTHolderContract} from "../../src/NFTHolderContract.sol";
import {MarketPlace} from "../../src/MarketPlace.sol";
import {Test, console} from "forge-std/Test.sol";
import {WrappedEth} from "../../src/WrappedEthFucet.sol";
import {DeployDoodlePepe} from "../../script/DeployDoodlePepe.s.sol";
import {DoodlePepeNft} from "../../src/DoodlePepe.sol";

contract MarketPlaceTest is Test {
    NFTHolderContract nftContractHolder;
    MarketPlace marketPlace;
    WrappedEth wrappedEth;
    DoodlePepeNft doodlePepeNft;
    address interactingAddress;
    address buyerAddress;
    uint256 privateKey;

    function setUp() external {
        DeployMarketPlace deployMarketPlace = new DeployMarketPlace();
        (nftContractHolder, marketPlace, wrappedEth, privateKey) = deployMarketPlace.run();
        DeployDoodlePepe deployDoodle = new DeployDoodlePepe();
        doodlePepeNft = deployDoodle.run();
        interactingAddress = makeAddr("testAddress");
        buyerAddress = makeAddr("buyerAddress");
    }

    //NFT contract Holder

    /**
     * @dev Testing MarketPlace is the owner of NftContract Holder
     */
    function testOwnerOf() public view {
        address owner = nftContractHolder.owner();
        address expected = address(marketPlace);
        vm.assertEq(owner, expected);
    }

    /**
     * @dev Test Not Owner Trying to withdraw
     */
    function testNoneOwnerWithdraw() public {
        vm.prank(interactingAddress);
        vm.expectRevert();
        nftContractHolder.withdrawEth(1 ether, address(wrappedEth), interactingAddress);
    }

    function _mintAndList(uint256 nftIndex) internal {
        nftIndex = bound(nftIndex, 0, 3);
        vm.startPrank(interactingAddress);
        doodlePepeNft.mintNft(nftIndex);
        doodlePepeNft.approve(address(marketPlace), 1);
        //    address _erc721ContractAddress,
        // uint256 _erc721TokenId,
        // uint256 _listingAmount
        marketPlace.listNFT(address(doodlePepeNft), 1, 0.001 ether);
        vm.stopPrank();
    }

    /**
     *
     * @param nftIndex of nft to mint
     * @dev testing NFT Holder Contract Receive when user list NFT
     */
    function testnftContractHolderBalanceIncrease(uint256 nftIndex) public {
        _mintAndList(nftIndex);

        uint256 balanceOfNftHolder = doodlePepeNft.balanceOf(address(nftContractHolder));
        vm.assertEq(balanceOfNftHolder, 1);
    }

    /**
     *
     * @param nftIndex index of Nft to mint
     * Test if user unlist is success
     */
    function testUnlistNft(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        vm.prank(interactingAddress);
        //     address _erc721ContractAddress,
        // uint256 _erc721TokenId
        marketPlace.unListNft(address(doodlePepeNft), 1);
        uint256 balanceOf = doodlePepeNft.balanceOf(address(nftContractHolder));
        assertEq(balanceOf, 0);
    }

    function testUserlistingBalance(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        uint256 balanceOf = marketPlace.getUserListedNfts(address(interactingAddress)).length;
        vm.assertEq(balanceOf, 1);
    }

    function testOwnerBalanceOfUserAfterUnlist(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        vm.startPrank(interactingAddress);
        marketPlace.unListNft(address(doodlePepeNft), 1);
        uint256 balanceOf = marketPlace.getUserListedNfts(interactingAddress).length;
        vm.assertEq(balanceOf, 0);
        vm.stopPrank();
    }

    function testNoneOwnerUnlist(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        address attacker = makeAddr("attacker");
        vm.startPrank(attacker);
        vm.expectRevert(MarketPlace.MarketPlace__OnlyTokeOwnerCanUnlist.selector);
        marketPlace.unListNft(address(doodlePepeNft), 1);
        uint256 balanceOf = marketPlace.getUserListedNfts(interactingAddress).length;
        vm.assertEq(balanceOf, 1);
        vm.stopPrank();
    }

    function _buyNft() internal {
        vm.startPrank(buyerAddress);

        wrappedEth.mint();
        wrappedEth.approve(address(marketPlace), 0.001 ether);
        marketPlace.buyNft(address(doodlePepeNft), 0, 0.001 ether);
        vm.stopPrank();
    }

    function testBuying(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        _buyNft();
        uint256 balanceOf = doodlePepeNft.balanceOf(buyerAddress);
        vm.assertEq(balanceOf, 1);
    }

    function testUserBalanceAfterBuy(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        _buyNft();
        uint256 balanceOfUser = marketPlace.getUserBalance(interactingAddress);
        uint256 expectedBalance = 0.00001 ether;
        assertEq(balanceOfUser, 0.001 ether - expectedBalance);
    }

    function testPercentageCalculator() public view {
        uint256 percentage = marketPlace._percentageCalculator(1 ether);
        uint256 expectedResult = 0.01 ether;
        vm.assertEq(percentage, expectedResult);
    }

    function testUserWithdraw(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        _buyNft();
        vm.startPrank(interactingAddress);
        uint256 balanceOf = marketPlace.getUserBalance(interactingAddress);
        marketPlace.withdraw(balanceOf);
        uint256 balanceAfterWithdraw = wrappedEth.balanceOf(interactingAddress);
        vm.assertEq(balanceAfterWithdraw, balanceOf);
        vm.stopPrank();
    }

    function testUserWithdrawMoreThanBalance(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        _buyNft();
        vm.startPrank(interactingAddress);
        vm.expectRevert(MarketPlace.MarketPlace__NotEnoughBalance.selector);
        marketPlace.withdraw(0.002 ether);

        vm.stopPrank();
    }

    function testNonOwnerWithdrawPercentage(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        _buyNft();
        vm.startPrank(interactingAddress);
        vm.expectRevert(MarketPlace.MarketPlace__OnlyOwner.selector);
        uint256 expectedBalance = 0.00001 ether;
        marketPlace.withdrawEarnedPercentage(expectedBalance);

        vm.stopPrank();
    }

    function testOwnerWithdrawPercentage(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        _buyNft();
        vm.startBroadcast(privateKey);
        uint256 expectedBalance = 0.00001 ether;
        marketPlace.withdrawEarnedPercentage(expectedBalance);
        uint256 balance = marketPlace.getEarnedPercentage();
        vm.assertEq(balance, 0);
        vm.stopBroadcast();
    }

    function testBalanceOfUserAfterBuying(uint256 nftIndex) public {
        _mintAndList(nftIndex);
        _buyNft();
        uint256 balanceOf = marketPlace.getUserListedNfts(interactingAddress).length;
        vm.assertEq(balanceOf, 0);
    }
}
