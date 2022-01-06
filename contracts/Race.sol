// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Staking distributes the CRACE rewards based on staked CRACE to each user.

contract Staking is Ownable {
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many CRACE tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 timestamp;
    }

    //a year: 31536000 secs

    // Info of each pool.
    struct PoolInfo {
        uint256 lockTime;           // a month: 2592000 secs
        uint256 apy;                // APY
        uint256 withdrawFee;        // Fee percentage for withdrawing anytime
        uint256 stakedAmount;
        uint256 compoundedAmount;
    }

    // Address of the CRACE Token contract.
    IERC20 public crace;
    // The total amount of CRACE that's paid out as reward.
    uint256 public paidOut = 0;

    // The total amount for rewards.
    uint256 public rewardsAmount = 0;

    // Total Withdraw Fee Amount
    uint256 public feeAmount = 0;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes BEP20 tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    event ClaimReward(address indexed user, uint256 indexed pid, uint256 amount);
    event Compound(address indexed user, uint256 indexed pid, uint256 amount);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(IERC20 _crace) {
        crace = _crace;
    }

    // Number of staking pools
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Fund the Staking
    function fund(uint256 _amount) external onlyOwner {
        rewardsAmount = rewardsAmount + _amount;
        crace.transferFrom(address(msg.sender), address(this), _amount);
    }

    function add(uint256 _lockTime, uint256 _apy, uint256 _withdrawFee) external onlyOwner {
        poolInfo.push(PoolInfo({
            lockTime: _lockTime,
            apy: _apy,
            withdrawFee: _withdrawFee,
            stakedAmount: 0,
            compoundedAmount: 0
        }));
    }

    function updatePool(uint256 _pid, uint256 _lockTime, uint256 _apy, uint256 _withdrawFee) external onlyOwner {
        poolInfo[_pid].lockTime = _lockTime;
        poolInfo[_pid].apy = _apy;
        poolInfo[_pid].withdrawFee = _withdrawFee;
    }

    // View function to see deposited BEP20 for a user.
    function deposited(uint256 _pid, address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user];
        return user.amount;
    }

    function pending(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        return user.amount * pool.apy * (block.timestamp - user.timestamp) / 3153600000 + user.rewardDebt;
    }

    function claimReward(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.timestamp - user.timestamp >= pool.lockTime, "claim: locked");
        uint256 pendingAmount = user.amount * pool.apy * (block.timestamp - user.timestamp) / 3153600000 + user.rewardDebt;
        require(pendingAmount <= rewardsAmount, "Not enough rewards amount");
        user.timestamp = block.timestamp;
        user.rewardDebt = 0;
        paidOut += pendingAmount;
        rewardsAmount = rewardsAmount - pendingAmount;
        crace.safeTransfer(address(msg.sender), pendingAmount);
        emit ClaimReward(msg.sender, _pid, pendingAmount);
    }

    function compound(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 pendingAmount = user.amount * pool.apy * (block.timestamp - user.timestamp) / 3153600000 + user.rewardDebt;
        require(pendingAmount > 0, "compound: wrong amount");
        require(pendingAmount <= rewardsAmount, "Not enough rewards amount");
        rewardsAmount = rewardsAmount - pendingAmount;
        user.rewardDebt = 0;
        user.timestamp = block.timestamp;
        user.amount = user.amount + pendingAmount;
        paidOut += pendingAmount;
        pool.stakedAmount = pool.stakedAmount + pendingAmount;
        pool.compoundedAmount = pool.compoundedAmount + pendingAmount;
        emit Compound(msg.sender, _pid, pendingAmount);
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(_amount > 0, "deposit: wrong amount");
        crace.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.rewardDebt = user.amount * pool.apy * (block.timestamp - user.timestamp) / 3153600000 + user.rewardDebt;
        user.timestamp = block.timestamp;
        user.amount = user.amount + _amount;
        pool.stakedAmount = pool.stakedAmount + _amount;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.timestamp - user.timestamp >= pool.lockTime, "withdraw: locked");
        require(user.amount >= _amount && _amount > 0, "withdraw: wrong amount");
        user.rewardDebt = user.amount * pool.apy * (block.timestamp - user.timestamp) / 3153600000 + user.rewardDebt;
        user.timestamp = block.timestamp;
        user.amount = user.amount - _amount;
        pool.stakedAmount = pool.stakedAmount - _amount;
        crace.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.timestamp - user.timestamp < pool.lockTime, "withdraw: unlocked");
        pool.stakedAmount = pool.stakedAmount - user.amount;
        uint256 amount = user.amount * (100 - pool.withdrawFee) / 100;
        feeAmount = feeAmount + (user.amount * (pool.withdrawFee / 100));
        user.amount = 0;
        user.timestamp = block.timestamp;
        user.rewardDebt = 0;
        crace.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
    }

    //Get total amount of withdraw fee
    function getWithdrawFeeAmount() external view returns(uint256) {
        return feeAmount;
    }

    //Add withdraw fee amount to rewards amount
    function addWithdrawFeeToRewards() external onlyOwner {
        rewardsAmount = rewardsAmount + feeAmount;
        feeAmount = 0;
    }

    //Withdraw fee amount to address _to
    function withdrawFeeAmount(address _to) external onlyOwner {
        require(feeAmount > 0, "Not enough Fee Amount");   
        crace.safeTransferFrom(address(this), _to, feeAmount);
        feeAmount = 0;
    }

    //Withdraw rewards amount to address _to
    function withdrawRewards(address _to) external onlyOwner {
        require(rewardsAmount > 0, "Not enough Rewards Amount");
        crace.safeTransferFrom(address(this), _to, rewardsAmount);
        rewardsAmount = 0;
    }

    //Withraw total amount of contract to address _to
    function withdrawFunds(address _to) external onlyOwner {
        uint256 balance = crace.balanceOf(address(this));
        crace.safeTransfer(_to, balance);
    }
}