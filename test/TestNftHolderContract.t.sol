// //SPDX-License-Identifier:MIT
// pragma solidity >=0.8.0 <0.9.0;
// import {Test} from "forge-std/Test.sol";
// import {NFTHolderContract} from "../src/NFTHolderContract.sol";
// import {TestNFT} from "../src/TestNFT.sol";
// import {DeployMarketPlace} from "../script/DeployMarketPlace.s.sol";

// contract TestNftHolderContract is Test {
//     NFTHolderContract nftHolderContract;
//     TestNFT testNft;
//     address mintAddress;
//     address owner;
//     function setUp() external {
//         DeployMarketPlace deployMarketPlace = new DeployMarketPlace();
//         (nftHolderContract, testNft, owner) = deployMarketPlace.run();
//         mintAddress = makeAddr("mintAddress");
//         vm.prank(mintAddress);
//         testNft.mintNFt();
//     }

//     function testMintNft() public view {
//         uint256 balanceOf = testNft.balanceOf(mintAddress);
//         vm.assertEq(balanceOf, 1);
//     }

//     function testContractReceived() public {
//         vm.startPrank(mintAddress);
//         testNft.transferFrom(mintAddress, address(nftHolderContract), 1);
//         uint256 balanceOfContract = testNft.balanceOf(
//             address(nftHolderContract)
//         );
//         vm.assertEq(balanceOfContract, 1);
//     }

//     function testTransfer() public {
//         vm.startPrank(mintAddress);
//         testNft.transferFrom(mintAddress, address(nftHolderContract), 1);
//         vm.startPrank(owner);
//         nftHolderContract.transferToken(mintAddress, address(testNft), 1);
//         uint256 balanceOf = testNft.balanceOf(mintAddress);
//         vm.assertEq(balanceOf, 1);
//     }
//     function testNotOwnerTransfer() public {
//         vm.startPrank(mintAddress);
//         testNft.transferFrom(mintAddress, address(nftHolderContract), 1);
//         vm.expectRevert();
//         vm.startPrank(mintAddress);
//         nftHolderContract.transferToken(mintAddress, address(testNft), 1);
//     }
// }
