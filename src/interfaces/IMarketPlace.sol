//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;
interface IMarketPlace {
    function listNFT(
        address _erc721ContractAddress,
        uint256 _erc721TokenId,
        uint256 _listingAmount
    ) external;
}
