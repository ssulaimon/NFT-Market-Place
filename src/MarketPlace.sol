// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

//SPDX-License-Identifier:MIT

/*
 * @dev this contract is a NFT Market place where user can list thier NFT for sale
 * @dev this contract follows the CEI pattern
 */
pragma solidity >=0.8.0 <0.9.0;
import {IMarketPlace} from "../src/interfaces/IMarketPlace.sol";
import {IERC721} from "@openzeppelin/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {NFTHolderContract} from "../src/NFTHolderContract.sol";

contract MarketPlace is IMarketPlace {
    // Custom Errors
    error MarketPlace__OnlyTokenOwnerCanListToken(
        address _owner,
        address _from
    );
    error MarketPlace__OnlyTokeOwnerCanUnlist();
    error MarketPlace__TransferFailed();
    error MarketPlace__IndexNotFound();
    error MarketPlace__AmountLessThanSaleValue();
    error MarketPlace__InvalidValue();

    // Events

    // Types Declarations
    struct NftsModels {
        address erc721Address;
        uint256 erc721TokenId;
        uint256 listingAmount;
        address owner;
    }

    // State Variables

    mapping(address user => NftsModels[]) private s_userListedNFts;
    mapping(address erc721Address => mapping(uint256 tokenId => address tokenOwner))
        private s_tokenOwner;
    mapping(address erc721Address => bool) private s_alreadyExisted; // This checks if a token from same collection have been listed previously
    mapping(address erc721Addresses => NftsModels[] listingDetails)
        private s_listedNftsCollections; // This keep tracks of all listed Nft under a specific collection
    mapping(address user => uint256 amount) s_userBalance; // This keeps track of how much a user can withdraw from the contract
    address private immutable i_nftHolderContract;
    address[] private s_erc721Addresses; // Unqiue ERC71 Contract Addresses
    address private immutable i_wrappedEthAddress;

    // Modifiers

    // This modifier checks if caller is owner of the token they want to unlist
    modifier checkOwerOfToken(
        address _from,
        address _erc721Address,
        uint256 _tokenId
    ) {
        address expectedCaller = s_tokenOwner[_erc721Address][_tokenId];
        if (_from != expectedCaller) {
            revert MarketPlace__OnlyTokeOwnerCanUnlist();
        }
        _;
    }

    modifier checkZeroWithdraw(uint256 _amount) {
        if (_amount <= 0) {
            revert MarketPlace__InvalidValue();
        }
        _;
    }

    // Constructor
    constructor(address _nftHolderContract, address _wrappedEth) {
        i_nftHolderContract = _nftHolderContract;
        i_wrappedEthAddress = _wrappedEth;
    }

    // External Functions

    /*
     * @param  _erc721ContractAddress: This is the Nft contract address that user want to list on the market place
     * @param _erc721TokenId: The token id user want to list on the market place
     * @param _listingAmount: The eth Amount user want to list the token for
     * @dev only the owner of the token can call this function
     */

    function listNFT(
        address _erc721ContractAddress,
        uint256 _erc721TokenId,
        uint256 _listingAmount
    ) external {
        _listNFT(
            _erc721ContractAddress,
            _erc721TokenId,
            _listingAmount,
            msg.sender
        );
        IERC721(_erc721ContractAddress).safeTransferFrom(
            msg.sender,
            i_nftHolderContract,
            _erc721TokenId,
            ""
        );
    }

    /*
     * @param  _erc721ContractAddress: The token contract address user want to remove from the market place
     * @param _erc721TokenId: The token id user want to unlist from the market
     * @dev call this function to remove nft from the market place
     */
    function unListNft(
        address _erc721ContractAddress,
        uint256 _erc721TokenId
    )
        external
        checkOwerOfToken(msg.sender, _erc721ContractAddress, _erc721TokenId)
    {
        _removeFromUserList(msg.sender, _erc721ContractAddress, _erc721TokenId);
        _removeFromListedCollection(_erc721ContractAddress, _erc721TokenId);
        s_tokenOwner[_erc721ContractAddress][_erc721TokenId] = address(0);

        bool isSuccess = NFTHolderContract(i_nftHolderContract).transferToken(
            msg.sender,
            _erc721ContractAddress,
            _erc721TokenId
        );
        if (!isSuccess) {
            revert MarketPlace__TransferFailed();
        }
    }

    function buyNft(
        address _erc721Address,
        uint256 _index,
        uint256 _amount
    ) external {
        NftsModels memory _nftModel = s_listedNftsCollections[_erc721Address][
            _index
        ];
        if (_amount < _nftModel.listingAmount) {
            revert MarketPlace__AmountLessThanSaleValue();
        }
        _removeFromUserList(
            _nftModel.owner,
            _erc721Address,
            _nftModel.erc721TokenId
        );
        _removeFromListedCollection(_erc721Address, _nftModel.erc721TokenId);
        s_tokenOwner[_erc721Address][_nftModel.erc721TokenId] = address(0);
        bool isSucessful = IERC20(i_wrappedEthAddress).transferFrom(
            msg.sender,
            i_nftHolderContract,
            _amount
        );
        s_userBalance[_nftModel.owner] += _percentageCalculator(_amount);
        if (!isSucessful) {
            revert MarketPlace__TransferFailed();
        }
    }

    function withdraw(uint256 _amount) external checkZeroWithdraw(_amount) {
        s_userBalance[msg.sender] -= _amount;
        bool isSuccessful = NFTHolderContract(i_nftHolderContract).withdrawEth(
            _amount,
            i_wrappedEthAddress,
            msg.sender
        );
        if (!isSuccessful) {
            revert MarketPlace__TransferFailed();
        }
    }

    //Private Functions

    function _listNFT(
        address _erc721ContractAddress,
        uint256 _erc721TokenId,
        uint256 _listingAmount,
        address _from
    ) private {
        address tokenOwner = IERC721(_erc721ContractAddress).ownerOf(
            _erc721TokenId
        );
        if (_from != tokenOwner) {
            revert MarketPlace__OnlyTokenOwnerCanListToken(tokenOwner, _from);
        }
        NftsModels memory _nftModel = NftsModels({
            erc721Address: _erc721ContractAddress,
            erc721TokenId: _erc721TokenId,
            listingAmount: _listingAmount,
            owner: _from
        });
        if (s_alreadyExisted[_erc721ContractAddress] != true) {
            s_alreadyExisted[_erc721ContractAddress] = true;
            s_erc721Addresses.push(_erc721ContractAddress);
        }
        s_listedNftsCollections[_erc721ContractAddress].push(_nftModel);
        s_userListedNFts[_from].push(_nftModel);
        s_tokenOwner[_erc721ContractAddress][_erc721TokenId] = _from; // Keep tracks of owner of a token
    }

    /*
     * @param  _owner: This the address of user that listed the nft token
     * @param  _erc721Address: The contract of erc721 that needs to be unlisted
     * @param _tokenId: The token id of the erc721 that needs to be unlisted
     * @dev This function makes sure the unlisted token is removed from list of tokens user have listed on the market place, also make sure there is no empty slot in the array if an index is removed
     */

    function _removeFromUserList(
        address _owner,
        address _erc721Address,
        uint256 _tokenId
    ) private {
        NftsModels[] memory userNfts = s_userListedNFts[_owner];
        for (uint256 index = 0; index < userNfts.length; index++) {
            if (
                userNfts[index].erc721TokenId == _tokenId &&
                userNfts[index].erc721Address == _erc721Address
            ) {
                delete s_userListedNFts[_owner][index]; // Remove token from list
                if (userNfts.length > 1) {
                    // This makes sure there is no empty sloth in the array
                    s_userListedNFts[_owner][index] = s_userListedNFts[_owner][
                        userNfts.length - 1
                    ];

                    s_userListedNFts[_owner].pop();
                } else {
                    //This make sure an empty array is returned if user does not have any other nft listed
                    s_userListedNFts[_owner].pop();
                }

                break;
            }
        }
    }

    function _removeFromListedCollection(
        address _erc721Address,
        uint256 tokenId
    ) private {
        uint256 length = s_listedNftsCollections[_erc721Address].length;
        for (uint256 index = 0; index < length; index++) {
            if (
                s_listedNftsCollections[_erc721Address][index].erc721TokenId ==
                tokenId
            ) {
                delete s_listedNftsCollections[_erc721Address][index];
                if (length > 1) {
                    s_listedNftsCollections[_erc721Address][
                        index
                    ] = s_listedNftsCollections[_erc721Address][length - 1];
                    s_listedNftsCollections[_erc721Address].pop();
                } else {
                    s_listedNftsCollections[_erc721Address].pop();
                }
                break;
            }
        }
    }

    function _percentageCalculator(
        uint256 _amount
    ) public pure returns (uint256) {
        return (_amount * 1) / 10000;
    }
    // View Functions
    function getUserListedNfts(
        address _user
    ) public view returns (NftsModels[] memory) {
        return s_userListedNFts[_user];
    }

    function getUserBalance(address _user) public view returns (uint256) {
        return s_userBalance[_user];
    }

    function getNftBalanceOf(
        address _erc721Address
    ) public view returns (uint256) {
        return IERC721(_erc721Address).balanceOf(i_nftHolderContract);
    }

    function getTokensListedInCollections(
        address erc721CollectionContractAddress
    ) public view returns (NftsModels[] memory) {
        return s_listedNftsCollections[erc721CollectionContractAddress];
    }

    function getListedCollectionAddress()
        public
        view
        returns (address[] memory)
    {
        return s_erc721Addresses;
    }
}
