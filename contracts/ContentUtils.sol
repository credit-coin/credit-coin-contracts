pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

library DeliverableUtils {

    struct Deliverable {
        uint256 reward;
        mapping(address=>bool) fulfillment;
    }

    /// @notice msg.sender can be creator or brand and mark their delivery or approval, returns check if completely Fulfilled
    function fulfill(Deliverable storage self, address _creator, address _brand) internal returns(bool) {
        require(msg.sender == _creator || msg.sender == _brand);
        self.fulfillment[msg.sender] = true;
        return self.fulfillment[_creator] && self.fulfillment[_brand];
    }

    /// @notice check if deliverable fulfilled completely
    function isFulfilled(Deliverable storage self, address _creator, address _brand) internal view returns(bool) {
        return self.fulfillment[_creator] && self.fulfillment[_brand];
    }

    /// @notice return new deliverable struct if reward greater than 0
    function newDeliverable(uint256 _reward) internal pure returns(Deliverable _deliverable) {
        require(_reward > 0);
        return Deliverable(_reward);
    }
}

library ContentUtils {
    using SafeMath for uint256;
    using DeliverableUtils for DeliverableUtils.Deliverable;

    struct Content {
        bytes32 id;
        string name;
        string description;
        uint addedOn;
        DeliverableUtils.Deliverable deliverable;
    }

    /// @notice utility for mapping bytes32=>Content. Keys must be unique. It can be updated until it is locked.
    struct ContentMapping {
        mapping(bytes32=>Content) data;
        bytes32[] keys;
        bool locked;
    }

    string constant UNIQUE_KEY_ERR = "Content with ID already exists ";
    string constant KEY_NOT_FOUND_ERR = "Key not found";

    /// @notice put item into mapping
    function put(ContentMapping storage self, 
        string _name, 
        string _description, 
        uint _addedOn,
        uint _reward) public returns (bool) 
    {
            require(!self.locked);

            bytes32 _id = generateContentID(_name);
            require(self.data[_id].id == bytes32(0));

            self.data[_id] = Content(_id, _name, _description, _addedOn, DeliverableUtils.newDeliverable(_reward));
            self.keys.push(_id);
            return true;
    }
    
    /// @notice get amount of items in mapping
    function size(ContentMapping storage self) public view returns (uint) {
        return self.keys.length;
    }

    /// @notice return reward of content delivarable
    function rewardOf(ContentMapping storage self, bytes32 _id) public view returns (uint256) {
        return self.data[_id].deliverable.reward;
    }

    function getKey(ContentMapping storage self, uint _index) public view returns (bytes32) {
        isValidIndex(_index, self.keys.length);
        return self.keys[_index];
    }

    /// @notice get content by plain string name
    function getContentByName(ContentMapping storage self, string _name) public view returns (Content storage _content, bool exists) {
        bytes32 _hash = generateContentID(_name);
        return (self.data[_hash], self.data[_hash].id == bytes32(0));
    }

    /// @notice get content by sha3 ID hash
    function getContentByID(ContentMapping storage self, bytes32 _id) public view returns (Content storage _content, bool exists) {
        return (self.data[_id], self.data[_id].id == bytes32(0));
    }

    /// @notice get content by _index into key array 
    function getContentByKeyIndex(ContentMapping storage self, uint _index) public view returns (Content storage _content) {
        isValidIndex(_index, self.keys.length);
        return (self.data[self.keys[_index]]);
    }

    /// @notice wrapper around internal deliverable method
    function fulfill(ContentMapping storage self, bytes32 _id, address _creator, address _brand) public returns(bool) {
        return self.data[_id].deliverable.fulfill(_creator, _brand);
    }

    /// @notice wrapper around internal deliverable method
    function isFulfilled(ContentMapping storage self, bytes32 _id, address _creator, address _brand) public view returns(bool) {
        return self.data[_id].deliverable.isFulfilled(_creator, _brand);
    }

    /// @notice get sha256 hash of name for content ID
    function generateContentID(string _name) public pure returns (bytes32) {
        return keccak256(_name);
    }

    /// @notice index not out of bounds
    function isValidIndex(uint _index, uint _size) public pure {
        require(_index < _size, KEY_NOT_FOUND_ERR);
    }
}

