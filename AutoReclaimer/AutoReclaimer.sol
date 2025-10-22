// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title AutoReclaimer
/// @notice Allows an authorized manager to reclaim tokens from a list of addresses (requires those addresses to have approved this contract).
interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract AutoReclaimer {
    address public manager;
    address public treasury;
    event Reclaimed(address indexed token, address indexed from, uint256 amount);

    constructor(address _treasury) {
        manager = msg.sender;
        treasury = _treasury;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "manager");
        _;
    }

    // reclaim multiple allowances from targets that approved this contract
    function reclaim(address token, address[] calldata targets, uint256[] calldata amounts) external onlyManager {
        require(targets.length == amounts.length, "len");
        for(uint256 i=0;i<targets.length;i++){
            require(IERC20(token).transferFrom(targets[i], treasury, amounts[i]));
            emit Reclaimed(token, targets[i], amounts[i]);
        }
    }

    function setTreasury(address _t) external onlyManager {
        treasury = _t;
    }
}
