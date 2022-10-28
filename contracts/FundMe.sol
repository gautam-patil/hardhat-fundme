

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./PriceConverter.sol";

error NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    //Use constant, immutable to lower the gas
    uint256 public constant minimumUsd = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable owner;

    AggregatorV3Interface public priceFeed;

    constructor(address priceFeedAddress){
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable{

        // require(getConversionRate(msg.value) >= minimumUsd, "Didn't send enough!!");
        require(msg.value.getConversionRate(priceFeed) >= minimumUsd, "Didn't send enough!!");
        //18 decimals
        funders.push(msg.sender); //To store all sender list
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public {

        // require(msg.sender == owner, "Sender is not owner")

        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //reset the array
        funders = new address[](0);

        //msg.sender = address
        //payable(msg.sender) = payable address

        //transfer
        // payable(msg.sender).transfer(address(this).balance);

        //send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send Failed")

        //call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner {
        // require(msg.sender == owner, "Sender is not owner");
        if(msg.sender != owner) { revert NotOwner(); }
        _; // doing the rest of the code
    }

    // function withdraw(){}
}