//SPDX-License-Identifier:MIT
pragma solidity >0.8.0 <0.9.0;

import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";

//Holesky
//Contract address: 0x3b5555E9FDc9D955FD76718129cE47f2C7578420
contract DoodlePepeNft is ERC721 {
    error DoodlePepeNft__AddressMintedMaxNFT();
    error DoodlePepeNft__OutOfIndex();

    uint256 private s_tokenCounter;
    string[4] private s_tokenURIs;
    mapping(uint256 tokenId => string tokenURI) private s_tokenURI;
    mapping(address user => uint256 mintedNft) private s_userMintedNft;

    event MintedNFT(address indexed _minter, uint256 _tokenId);

    modifier checkUserMinted(address _user) {
        if (s_userMintedNft[_user] == 5) {
            revert DoodlePepeNft__AddressMintedMaxNFT();
        }
        _;
    }

    modifier checkIndex(uint256 indexSelected) {
        if (indexSelected > s_tokenURIs.length - 1) {
            revert DoodlePepeNft__OutOfIndex();
        }
        _;
    }

    constructor(string[4] memory _tokenURIs) ERC721("Doodle Pepe", "DDP") {
        s_tokenCounter = 1;
        s_tokenURIs = _tokenURIs;
    }

    function mintNft(uint256 _selectedNft) external checkUserMinted(msg.sender) checkIndex(_selectedNft) {
        s_userMintedNft[msg.sender] += 1;
        _mint(msg.sender, s_tokenCounter);
        s_tokenURI[s_tokenCounter] = s_tokenURIs[_selectedNft];
        s_tokenCounter++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenURI[tokenId];
    }

    function getTokenUris() public view returns (string[4] memory) {
        return s_tokenURIs;
    }
}
