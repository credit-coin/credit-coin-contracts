pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import 'tokencontract/contracts/CCOIN.sol';
import './ContentUtils.sol';

contract Escrow {
    using SafeMath for uint256;
    using ContentUtils for ContentUtils.ContentMapping;

    ContentUtils.ContentMapping public content;
    address escrowAddr = address(this);
    address public tokenAddr;
    CCOIN public creditCoin;

    uint256 public claimable = 0; 
    uint256 public currentBalance = 0; 

    constructor(address _token) {
        tokenAddr = _token;
        creditCoin = CCOIN(_token);
    }

    /// @notice valid reward and user has enough funds
    modifier validReward(uint256 _reward) {
        require(_reward > 0 && _depositEscrow(_reward));
        _;
    }

    /// @notice complete deliverable by making reward amount claimable
    function completeDeliverable(bytes32 _id, address _creator, address _brand) internal returns(bool) {
        require(content.isFulfilled(_id, _creator, _brand));
        content.completeDeliverable(_id);
        return _approveEscrow(content.rewardOf(_id));       
    }

    /// @notice update current balance, if proper token amount approved
    function _depositEscrow(uint256 _amount) internal returns(bool) {
        require(creditCoin.balanceOf(this) >= _amount.add(currentBalance));
        currentBalance = currentBalance.add(_amount);
        return true;
    }

    /// @notice approve reward amount for transfer from escrow contract to creator
    function _approveEscrow(uint256 _amount) internal returns(bool) {
        claimable = claimable.add(_amount);
        return true;
    }

    function getContentByName(string _name) public view returns(
        string name,
        string description,
        uint reward,
        uint addedOn) 
    {
        var (_content, exist) = content.getContentByName(_name);
        if (exist) {
            return (_content.name, _content.description, _content.deliverable.reward, _content.addedOn);
        } else {
            return ("", "", 0, 0);
        }
    }

    function currentFulfillment(string _name) public view returns(bool fulfillment) {
        var (_content, exist) = content.getContentByName(_name);
        if (exist) {
            return _content.deliverable.fulfillment[msg.sender];
        } else {
            false;
        }
    }
}
