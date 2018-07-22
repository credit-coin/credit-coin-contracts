pragma solidity ^0.4.23;

import './Escrow.sol';
import './ContentUtils.sol';

contract Agreement is Escrow {
    
    bool public locked;


    uint  public createdOn;
    uint public expiration;
    uint public startTime;
    address public brand;
    mapping (bytes32=>bool) public creators;

    string public title;
    string public description;
    string public client;
    string public reach;
    string public image;
    uint256 public numberOfPost;

    constructor(
        string _title,
        string _description,
        string _client,
        uint256 _budget,
        string _reach,
        string _image,
        uint _expiration,
        uint _startTime,
        uint256 _numberOfPost) public {
        brand = msg.sender;
        image = _image;
        title = _title;
        description = _description;
        client = _client;
        budget = _budget;
        reach = _reach;
        expiration = _expiration;
        startTime = _startTime;
        numberOfPost = _numberOfPost;
    }

    /// @notice only brand is authorized
    modifier onlyBrand() {
        require(msg.sender == brand);
        _;
    }

    /// @notice only creators is authorized
    modifier isInvited(bytes32 _creator) {
        require(creators[_creator]);
        _;
    }

    /// @notice deliverable fulfilled
    // modifier fulfilled(bytes32 _id) {
    //     require(content.isFulfilled(_id, creators, brand));
    //     _;
    // }

    // approve contentID
    /// @notice agreement expired, refunds remaining balance in escrow
    modifier expired() {
        require(block.timestamp > expiration);
        _;
    }

    /// @notice agreement not expire
    modifier notExpired() {
        require(block.timestamp < expiration);
        _;
    }

    /// @notice agreement not locked
    modifier notLocked() {
        require(!locked);
        _;
    }

    /// @notice submit content to the agreement
    function submitContent(
        bytes32 _creator,
        string _name, 
        string _description,
        string _type,
        string _contentID,
        string _userID) notExpired onlyBrand  isInvited(_creator) 
        public returns(bool) {
            return content.put(_name, _description, _type, _contentID, _userID);
    }

    /// @notice complete deliverable by making reward amount claimable, GENERATE PAYOUT
    function approveContent(bytes32 _contentID) onlyBrand public returns(bool) {
        content.approve(_contentID);
        ContentUtils.Content memory _content = content.getContentByID(_contentID);
        return newPayout(_content.id, _content.userID, _content.contentID);
    }

    /// @notice complete deliverable by making reward amount claimable, GENERATE PAYOUT
    function disApproveContent(bytes32 _contentID) onlyBrand public returns(bool) {
        content.disApprove(_contentID);
        payouts[_contentID].client = '';
        return true;
    }

    /// @notice complete deliverable by making reward amount claimable, GENERATE PAYOUT
    function requestEdit(bytes32 _contentID) onlyBrand public returns(bool) {
        content.requestEdit(_contentID);
        return true;
    }

    function requestResubmission(bytes32 _contentID) onlyBrand public returns(bool) {
        content.requestResubmission(_contentID);
        return true;
    }

    function extendExpiration(uint _expiration) onlyBrand public returns (bool) {
        require(_expiration > expiration && _expiration >= block.timestamp);
        expiration = _expiration;
        return true;
    }

    function addCreator(bytes32 _creator) onlyBrand public returns (bool) {
        creators[_creator] = true;
        return true;
    }

    function getCreator(bytes32 _creator) onlyBrand view returns (bool) {
        return creators[_creator];
    }
    // function _fulfill(bytes32 _id) private returns (bool) {
    //     bool _fulfilled = content.fulfill(_id, creators, brand);
    //     if(_fulfilled) {
    //         return completeDeliverable(_id, creators, brand);
    //     }

    //     return false;
    // }

    // function fulfillDeliverable(bytes32 _id) notExpired isInvited public returns (bool) {
    //     return _fulfill(_id);
    // }

    // function approveDeliverable(bytes32 _id) onlyBrand public returns (bool) {
    //     return _fulfill(_id);
    // }
    
    // function claim(bytes32 _id) external isInvited {
    //     claimableRewards[_id] = 0;
    // }

    // function lock() onlyBrand public {
    //     content.locked == true;
    //     locked = true;
    //     startTime = block.timestamp;
    // }

    

    // function destroy() onlyBrand expired public {
    //     selfdestruct(msg.sender);
    // }
}
