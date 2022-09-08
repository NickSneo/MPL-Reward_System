// SPDX-License-Identifier: MIT
/**
 * @file RewardSystem.sol
 * @author Nischal <snischal@vmware.com>
 * @date created 6th Sept 2022
 * @date last modified 7th Sept 2022
 */

pragma solidity ^0.8.0;

import "./RewardToken.sol";

contract RewardSystem {

    RewardToken public rt;
    address private owner;
    uint private deployedTime;
    uint maxRewardEachDay;

    /**
     * @dev rewardBalance - stores the address and reward claimed till now
     */
    mapping(address=>uint) private rewardBalance;

    /**
     * @dev deploys new Reward Token Smart Contract
     * Initializes deployedTime with current block timestamp
     */
    constructor (string memory _name, string memory _symbol, uint _maxRewardEachDay) {
        deployNewRT(_name, _symbol);
        owner = msg.sender;
        deployedTime = block.timestamp;
        maxRewardEachDay = _maxRewardEachDay;
    }

    /**
     * @dev Deployment of Reward Token, private fucntion
     * Returns rewardToken smart contract address
     */
    function deployNewRT (string memory _name, string memory _symbol) private returns (address){
        rt = new RewardToken(_name, _symbol, 0);
        return address(rt);
    }

    /**
     * @dev Function to claim reward tokens
     * Checks for max tokens allowed to claim each day
     * If some tokens are unclaimed on a day then it gets carry on to the next day 
     */
    function claimReward(uint amount) external {
        uint diff = ((block.timestamp - deployedTime) / 60 / 60 / 24) + 1 ;
        uint claimAmount = rewardBalance[msg.sender] + amount;
        require(claimAmount <= diff*maxRewardEachDay, "Amount claimed exceeding max allowed reward");
        rt.mintAndTransfer(amount, msg.sender);
        rewardBalance[msg.sender] += amount;
    }

    /**
     * @dev Calculates total unclaimed reward till now
     * Returns unclaimed tokens amount
     */
    function rewardLeft() public view returns (uint){
        uint diff = ((block.timestamp - deployedTime) / 60 / 60 / 24) + 1;
        return (diff*maxRewardEachDay - rewardBalance[msg.sender]);
    }

    /**
     * @dev Calculates total claimed reward till now
     * Returns claimed tokens amount
     */
    function rewardClaimed() public view returns (uint){
        return rewardBalance[msg.sender];
    }
}