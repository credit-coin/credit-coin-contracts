pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './ContentUtils.sol';

contract Escrow {
    using SafeMath for uint256;
    using ContentUtils for ContentUtils.ContentMapping;

    ContentUtils.ContentMapping public content;

    struct Payout {
        bytes32 id;
        string client;
        string contentID;
        bool isPayed;
    }

    uint256 public budget;  
    mapping (bytes32=>Payout) public payouts;
     
    /// @notice valid reward and user has enough funds
    // modifier validReward(uint256 _reward) {
    //     require(_reward > 0 && _depositEscrow(_reward));
    //     _;
    // }

    function newPayout(bytes32 _id, string _client, string _contentID) internal returns(bool) {
        payouts[_id] = Payout(_id, _client, _contentID, false);
        return true;
    }

    function payout(bytes32 _id) public returns(bool) {
        payouts[_id].isPayed = true;
        return true;
    }

    /// @notice update current balance, if proper token amount approved
    // function _depositEscrow(uint256 _amount) internal returns(bool) {
    //     currentBalance = currentBalance.add(_amount);
    //     return true;
    // }

    /// @notice approve reward amount for transfer from escrow contract to creator
    // function _approveEscrow(bytes32 _id, uint256 _amount) internal returns(bool) {
    //     claimable = claimable.add(_amount);
    //     claimableRewards[_id] = _amount;
    //     return true;
    // }

    // PAYOUT
    
    function getContentByID(bytes32 _contentID) public view returns(
        bytes32 id,
        uint addedOn,
        string name,
        string description,
        string _type,
        string contentID,
        string userID,
        bool approved, 
        bool requestEdit,
        bool requestResubmission) 
    {
        ContentUtils.Content memory _content = content.getContentByID(_contentID);
        return (
            _content.id,
            _content.addedOn,
            _content.name,
            _content.description,
            _content._type,
            _content.contentID,
            _content.userID,
            _content.approved, 
            _content.requestEdit,
            _content.requestResubmission
        );
    }

    // function currentFulfillment(string _name) public view returns(bool fulfillment) {
    //     var (_content, exist) = content.getContentByName(_name);
    //     if (exist) {
    //         return _content.deliverable.fulfillment[msg.sender];
    //     } else {
    //         false;
    //     }
    // }
}
