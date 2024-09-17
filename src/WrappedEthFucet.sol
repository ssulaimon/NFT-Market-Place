//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract WrappedEth is ERC20 {
    error WrappedEth__MintFail();

    event Minted(address indexed minter, uint256 amount);

    mapping(address => uint256) s_userMintedDate;

    constructor() ERC20("WrappedETH", "WETH") {}

    function _checkUserLastMinted(address _minter) internal view {
        if (((block.timestamp - s_userMintedDate[_minter]) / 1 days) < 1) {
            revert WrappedEth__MintFail();
        }
    }

    function mint() external {
        if (s_userMintedDate[msg.sender] == 0) {
            s_userMintedDate[msg.sender] = block.timestamp;
            _mint(msg.sender, 1 ether);
            emit Minted(msg.sender, 1 ether);
        } else {
            _checkUserLastMinted(msg.sender);
            s_userMintedDate[msg.sender] = block.timestamp;
            _mint(msg.sender, 1 ether);
            emit Minted(msg.sender, 1 ether);
        }
    }

    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }
}
