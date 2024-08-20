//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;
import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";

contract TestNFT is ERC721 {
    uint256 s_tokenCouner;
    constructor() ERC721("Test NFT", "TNF") {
        s_tokenCouner = 1;
    }

    function mintNFt() external {
        _mint(msg.sender, s_tokenCouner);
        s_tokenCouner++;
    }
}
