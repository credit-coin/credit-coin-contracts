pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './ContentUtils.sol';

contract Escrow {
    using SafeMath for uint256;
    using ContentUtils for ContentUtils.ContentMapping;

    ContentUtils.ContentMapping content;
    uint256 escrow = 0;

    /// @notice value sent with transaction covers reward
    modifier validReward(uint256 _reward) {
        require(msg.value > 0 && _reward > 0 && msg.value >= _reward);
        escrow.add(msg.value);
        _;
    }

    /// @notice complete deliverable by making reward amount claimable
    function completeDeliverable(bytes32 _id) internal returns(bool) {
        uint256 _reward = content.rewardOf(_id);
        require(_reward >= escrow);
        return withdraw(_reward);       
    }

    /// @notice withdraw an amount;
    function withdraw(uint256 _amount) internal returns(bool) {
        msg.sender.transfer(_amount);
        escrow.sub(_amount);
        return true;
    }
}
