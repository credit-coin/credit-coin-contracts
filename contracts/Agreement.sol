pragma solidity ^0.4.23;

contract Agreement {
    
    struct Milestone {
        uint target;
    }

    mapping(uint=>Milestone) milestones;
    uint balance;
    address brand;
    address contentCreator;

    constructor() public {
        brand = msg.sender;
    }

    /// @notice only brand is authorized
    modifier ownlyBrand(address sender) {
        require(sender == brand);
        _;
    }

    /// @notice only brand is authorized
    modifier ownlyBrand(address sender) {
        require(sender == brand);
        _;
    }

    function newMileStone(uint _target) ownlyBrand(msg.sender) uniqueMilestone(_target) public payable {
        milestones[_target] = Milestone(_target);
    } 
}
