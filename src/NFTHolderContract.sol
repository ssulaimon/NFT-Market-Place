//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;
import {IERC721Receiver} from "@openzeppelin/token/ERC721/IERC721Receiver.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {IERC721} from "@openzeppelin/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

contract NFTHolderContract is IERC721Receiver, Ownable {
    event ERC721Received(
        address indexed _sender,
        address _from,
        uint256 tokenId
    );
    constructor() Ownable(msg.sender) {}
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory /*data*/
    ) external returns (bytes4) {
        emit ERC721Received(from, operator, tokenId);
        return this.onERC721Received.selector;
    }

    function transferToken(
        address _to,
        address _erc721TokenContract,
        uint256 _tokenId
    ) external onlyOwner returns (bool) {
        IERC721(_erc721TokenContract).transferFrom(
            address(this),
            _to,
            _tokenId
        );
        return true;
    }
    function withdrawEth(
        uint256 _amount,
        address _erc20TokenAddress,
        address _to
    ) external onlyOwner returns (bool isSuccessful) {
        isSuccessful = IERC20(_erc20TokenAddress).transfer(_to, _amount);
    }

    function balanceOf(
        address _erc721TokenAddress
    ) external view returns (uint256) {
        return IERC721(_erc721TokenAddress).balanceOf(address(this));
    }
}
