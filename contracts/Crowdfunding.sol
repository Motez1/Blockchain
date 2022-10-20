// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address , uint) external returns(bool);
    function transferFrom(address, address, uint) external returns(bool);
}


contract Crowdfunding {

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint startsAt;
        uint endsAt;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public count;
    uint public maxDuration;

    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    event Launch (
        uint id,
        address indexed creator,
        uint goal,
        uint startsAt,
        uint endsAt
    );

    event Cancel (uint id);
    event Pledge (uint id, address caller ,uint amount);
    event Unpledge (uint id, address caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address caller, uint amount);

    constructor(address _token, uint _maxDuration) {
        token = IERC20(_token);
        maxDuration = _maxDuration;
    }

    function launch(uint _goal, uint _startsAt, uint _endsAt) external {
        require(_startsAt >= block.timestamp, "Start time is less than the current time");
        require(_endsAt > _startsAt, "End time is less than the start time");
        require(_endsAt <= block.timestamp + maxDuration,"End time exceeded maximum duration");

        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startsAt: _startsAt,
            endsAt: _endsAt,
            claimed: false
        });

        emit Launch(count,msg.sender,_goal,_startsAt,_endsAt);
    }

    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "Only the campaign creator can cancel the campaign");
        require(block.timestamp < campaign.startsAt, "The campaign ahs already started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startsAt, "The campaign has not started yet");
        require(block.timestamp <= campaign.endsAt, "The campaign has already ended");

        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unPledge(uint _id, uint _amount) external{
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startsAt, "The campaign has not started yet");
        require(block.timestamp <= campaign.endsAt, "The campaign has already ended");
        require(pledgedAmount[_id][msg.sender] >= _amount, "You don't have enough tokens pledged in this campaign");

        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id) external{
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "Only the campaign creator can claim the campaigns tokens");
        require(block.timestamp > campaign.endsAt, "The campaign has not ended yet");
        require(campaign.pledged >= campaign.goal, "The campaign has not succeeded yet");
        require(!campaign.claimed, "You have already claimed this campaign");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);

        emit Claim(_id);
    }
    
    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endsAt, "Campaign has not ended yet");
        require(campaign.pledged < campaign.goal, "Campaign has succeeded, you cannot refund");

        uint balance = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, balance);

        emit Refund(_id,msg.sender,balance);
    }
}


