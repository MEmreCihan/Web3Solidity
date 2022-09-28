// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}

contract CrowdFund {
    IERC20 public immutable token;
    uint public total;

    struct Campaign {
        address creator;
        uint goal;
        uint donation;
        uint32 startAt;
        uint32 endAt;
        bool completed;
    }

    Campaign[] public campaigns;
    mapping(uint => mapping(address => uint)) public donatedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

    event Launch(uint id, address indexed creator, uint goal, uint32 startAt, uint32 endAt);
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);

    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "Campaing can`t start in past");
        require(_endAt >= _startAt, "Campaing`s end time should be greater then start");
        require(_endAt <= block.timestamp, "Campaing should end in 90 days");

        total += 1;
        campaigns[total] = Campaign({
            creator: msg.sender,
            goal: _goal,
            donation: 0,
            startAt: _startAt,
            endAt: _endAt,
            completed: false
        });

        emit Launch(total, msg.sender, _goal, _startAt, _endAt);
    }

    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "You are not authorised");
        require(block.timestamp < campaign.startAt, "Campaign has not started yet");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "Campaign has not started yet");
        require(block.timestamp <= campaign.endAt, "Campaign has already ended");

        campaign.donation += _amount;
        donatedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "Campaign has already ended");

        campaign.donation -= _amount;
        donatedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "You are not authorised");
        require(block.timestamp > campaign.endAt, "Campaign is still going on");
        require(campaign.donation >= campaign.goal, "Campign must reach to the goal");
        require(!campaign.completed, "already claimed");

        campaign.completed = true;
        token.transfer(campaign.creator, campaign.donation);

        emit Claim(_id);
    }

    function refund(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "Campaign is still going on");
        require(campaign.donation < campaign.goal, "Campaign has reached to the goal");

        uint bal = donatedAmount[_id][msg.sender];
        donatedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }
}