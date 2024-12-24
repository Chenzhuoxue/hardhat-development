// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27;

import "./IERC20.sol";

/**
 * @title 质押奖励
 * @author chenzx913
 * @notice 
 */
contract SimpleStackingRewward {

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    address public owner;

    uint public totalStackingToken;

    uint public startAt;
    uint public finishAt;
    uint public duration;
    
    uint public rewardRate;

    mapping(address => Stacking) stackUsers;

    struct Stacking {
        uint balance;
        uint rewward;
        uint updateAt;        
    }

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "must owner");
        _;
    }

    modifier checkActivityTime {
        require(block.timestamp > startAt, "Activity not started");
        require(block.timestamp < finishAt, "Activity has finishAt");
        _;
    }

    modifier updateRewward(address user) {
         if (user != address(0)) {
            stackUsers[user].rewward += pendingReward(user);
            stackUsers[user].updateAt = block.timestamp;
        }
        _;
    }

    modifier updateRewwardRate() {
        _;    

    }

    function pendingReward(address user) private view returns(uint){
        Stacking memory stacker = stackUsers[user];
        return stacker.balance * rewardRate * (block.timestamp - stacker.updateAt) / totalStackingToken;
    }

    /**
     * 开始活动
     */
    function startActivity(uint _startAt, uint _duration, uint amount) external onlyOwner {
        startAt = _startAt;
        duration = _duration;
        finishAt = _startAt + _duration;
        rewardRate = amount / duration;
        totalStackingToken = 0;
        require(rewardsToken.balanceOf(address(this)) > amount, "reward token not enough");
    }

    /**
     * 添加奖励token
     * @param amount 奖励token数量 
     */
    function addRewardToken(uint amount) external onlyOwner {
        
    }

    /**
     * 质押token
     * @param amount 质押token数量
     */
    function stack(uint amount) external checkActivityTime updateRewward(msg.sender) updateRewwardRate {
        require(amount > 0, "Cannot stake 0");

        stakingToken.transferFrom(msg.sender, address(this), amount);
        stackUsers[msg.sender].balance += amount;
        totalStackingToken += amount;

    }

    /**
     * 赎回token
     * @param amount 赎回token数量
     */
    function withdraw(uint amount) external updateRewward(msg.sender) updateRewwardRate {
        require(amount > 0, "invalid amount");
        require(stackUsers[msg.sender].balance >= amount, "Insufficient balance");

        stackUsers[msg.sender].balance -= amount;
        totalStackingToken -= amount;
        stakingToken.transferFrom(address(this), msg.sender, amount);
    }

    /**
     * 查看自己的奖励token
     */
    function viewReward() external updateRewward(msg.sender) returns(uint) {
        return stackUsers[msg.sender].rewward;
    }

    /**
     * 提取奖励token
     */
    function getReward() external updateRewward(msg.sender) {
        rewardsToken.transferFrom(address(this), msg.sender, stackUsers[msg.sender].rewward);
        stackUsers[msg.sender].rewward = 0;
    }


}

