// SPDX-License-Identifier: MIT

// Smart contract that lets anyone deposit ETH into the contract

// Only the owner of the contract can withdraw the ETH

pragma solidity >=0.6.6 <0.9.0;

// Get the latest ETH/USD price from chainlink price feed

import "/Users/arik/.brownie/packages/smartcontractkit/chainlink-brownie-contracts@1.2.0/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//import "/Users/arik/.brownie/packages/smartcontractkit/chainlink-brownie-contracts@1.2.0/contracts/src/v0.8/vendor/SafeMathChainlink.sol";

contract FundMe {
    // safe math library check uint256 for integer overflows

    // using SafeMathChainlink for uint256;

    //mapping to store which address depositeded how much ETH

    mapping(address => uint256) public addressToAmountFunded;

    // array of addresses who deposited
    address[] public funders;

    //address of the owner (who deployed the contract)
    address payable public owner; // need this from Solidity 0.8

    AggregatorV3Interface public priceFeed;

    // the first person to deploy the contract is
    // the owner
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = payable(msg.sender);
    }

    function fund() public payable {
        // 18 digit number to be compared with donated amount
        uint256 minimumUSD = 50 * 10**18;
        //is the donated amount less than 50USD?
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH!"
        );
        //if not, add to mapping and funders array
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    //function to get the version of the chainlink pricefeed
    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        // ETH/USD rate in 18 digit
        return uint256(answer * 10**10);
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 10**18;
        return ethAmountInUsd;
    }

    // This is the threshold Wei amount to donate to contract
    function getEntranceFee() public view returns (uint256) {
        // minimum USD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    //modifier: https://medium.com/coinmonks/solidity-tutorial-all-about-modifiers-a86cf81c14cb

    modifier onlyOwner() {
        //is the message sender owner of the contract?
        require(msg.sender == owner);
        _;
    }

    // onlyOwner modifer will first check the condition inside it
    // and
    // if true, withdraw function will be executed

    function withdraw() public payable onlyOwner {
        // msg.sender.transfer(address(this).balance);
        payable(owner).transfer(address(this).balance);
        //iterate through all the mappings and make them 0
        //since all the deposited amount has been withdrawn
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //funders array will be initialized to 0
        funders = new address[](0);
    }
}
