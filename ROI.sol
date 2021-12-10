// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract invest {
  
    uint256 liquifyLimit = 1 ether;

    address public owner;

    struct User {
        uint256 invested_amount;
        uint256 profit;
        uint256 profit_withdrawn;
        uint256 start_time;
        uint256 exp_time;
        bool time_started;
        bool registered;
        uint256 regfee_profit;
    }

    mapping(address => User) public invest_map;

    mapping (address => uint) public balance; 

    address[] public MemberAddresses;

    constructor() public {
        owner = msg.sender;
    }

    function register() public payable {
        require(msg.value == 1 ether, "Please Enter Amount more than 0");
        balance[address(this)] += msg.value;   
        if (invest_map[msg.sender].registered == false) {
            invest_map[msg.sender].registered = true;
            MemberAddresses.push(msg.sender); 
        }
        if (balance[address(this)] == liquifyLimit) {
            uint256  regfee_prof = ( (balance[address(this)] * 67) / (1000));
            uint256 individual_prof = (regfee_prof / MemberAddresses.length);
            for(uint i=0;i<=MemberAddresses.length;i++){ 
                //balance[address(this)] -=regfee_prof;
                //invest_map[MemberAddresses[i]].regfee_profit = individual_prof;
            }
            
        }
    }

    function invest_fun() public payable {
        require(msg.value >= 0 && invest_map[msg.sender].registered == true, "Please register first and invest more than 0");
        if (invest_map[msg.sender].time_started == false) {
            invest_map[msg.sender].start_time = block.timestamp;
            invest_map[msg.sender].time_started = true;
            invest_map[msg.sender].exp_time = block.timestamp + 30 days;
        }
        invest_map[msg.sender].invested_amount += msg.value;
        invest_map[msg.sender].profit += ( (msg.value * 171 * 30 ) / (10000));
    }

    function getBalance() public view returns (uint256) {
        return balance[address(this)];
    }

    function current_profit() public view returns (uint256) {
        uint256 local_profit;
        if (block.timestamp <= invest_map[msg.sender].exp_time) {
            if ( (((invest_map[msg.sender].profit + invest_map[msg.sender].profit_withdrawn) * (block.timestamp - invest_map[msg.sender].start_time)) / (30 * (1 days))) > invest_map[msg.sender].profit_withdrawn ) {
            local_profit = (((invest_map[msg.sender].profit + invest_map[msg.sender].profit_withdrawn) * (block.timestamp - invest_map[msg.sender].start_time)) / (30 * (1 days))) - invest_map[msg.sender].profit_withdrawn; 
            return local_profit;
            } else {
                return 0;
            }
        }
        if (block.timestamp > invest_map[msg.sender].exp_time) {
            return invest_map[msg.sender].profit;
        }
    }

    function withdraw_profit() public payable returns(bool){
        uint256 current_profit = current_profit();
        invest_map[msg.sender].profit_withdrawn = invest_map[msg.sender].profit_withdrawn + current_profit;
        invest_map[msg.sender].profit = invest_map[msg.sender].profit - current_profit;
        payable(msg.sender).transfer(current_profit);
        return true;
    }
}