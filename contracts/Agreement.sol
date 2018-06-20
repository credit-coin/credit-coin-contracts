pragma solidity ^0.4.23;

import './Escrow.sol';
import './ContentUtils.sol';

contract Agreement is Escrow {
    
    bool public locked;
    uint  public createdOn;
    uint public expiration;
    uint public startTime;
    address public brand;
    address public creator;
    
    constructor(address _creator, uint _expiration, address _token) Escrow(_token) public {
        brand = msg.sender;
        creator = _creator;
        expiration = _expiration;
    }

    /// @notice only brand is authorized
    modifier onlyBrand() {
        require(msg.sender == brand);
        _;
    }

    /// @notice only creator is authorized
    modifier onlyCreator() {
        require(msg.sender == creator);
        _;
    }

    /// @notice deliverable fulfilled
    modifier fulfilled(bytes32 _id) {
        require(content.isFulfilled(_id, creator, brand));
        _;
    }

    /// @notice agreement expired, refunds remaining balance in escrow
    modifier expired() {
        require(block.timestamp > expiration);
        _;
    }

    /// @notice agreement not expired, refunds remaining balance in escrow
    modifier notExpired() {
        require(block.timestamp < expiration);
        _;
    }

    /// @notice agreement not locked
    modifier notLocked() {
        require(!locked);
        _;
    }

    /// @notice add content to the agreement
    function addContent(string _name, 
        string _description, 
        uint _reward) notLocked onlyBrand validReward(_reward) 
        public returns(bool _success) {
            return content.put(_name, _description, _reward);
    }

    function _fulfill(bytes32 _id) private returns (bool) {
        bool _fulfilled = content.fulfill(_id, creator, brand);
        if(_fulfilled) {
            return completeDeliverable(_id, creator, brand);
        }

        return false;
    }

    function fulfillDeliverable(bytes32 _id) notExpired onlyCreator public returns (bool) {
        return _fulfill(_id);
    }

    function approveDeliverable(bytes32 _id) onlyBrand public returns (bool) {
        return _fulfill(_id);
    }
    
    function claim(bytes32 _id) external onlyCreator {
        claimableRewards[_id] = 0;
    }


    function lock() onlyBrand public {
        content.locked == true;
        locked = true;
        startTime = block.timestamp;
    }

    function extendExpiration(uint _expiration) onlyBrand public returns (bool) {
        require(_expiration > expiration && _expiration >= block.timestamp);
        expiration = _expiration;
        return true;
    }

    function destroy() onlyBrand expired public {
        selfdestruct(msg.sender);
    }

    function deposit() payable {}
}
