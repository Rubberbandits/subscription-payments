//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract SubscriptionPayments is Ownable, PaymentSplitter {
    // Storage
    uint256 price = 0.5 ether;
    uint32 subscriptionTime = 30 days;
    uint16 maxSubscriptions = 50;

    mapping(address => uint256) public subscriptions;
    address[] public subscriptionKeys;

    // Constructor
    constructor(address[] memory payees, uint256[] memory shares_) PaymentSplitter(payees, shares_) {
    }

    // Payment facilitator
    receive() override external payable {
        require(msg.value >= price, "Insufficient value");

        if (subscriptions[_msgSender()] < block.timestamp) {
            require(subscriptionKeys.length < maxSubscriptions, "No slots");
        }

        subscriptions[_msgSender()] = block.timestamp + subscriptionTime;
        subscriptionKeys.push(_msgSender());

        emit PaymentReceived(_msgSender(), msg.value);
    }

    // View
    function getSubscriptionCount() public view returns (uint256 length) {
        return subscriptionKeys.length;
    }

    function getSubscriptionByIndex(uint256 index) public view returns (uint256 timestamp) {
        return subscriptions[subscriptionKeys[index]];
    }

    // Management functions
    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function setMaxSubscriptions(uint16 _maxSubscriptions) external onlyOwner {
        maxSubscriptions = _maxSubscriptions;
    }

    function setSubscriptionTime(uint32 _subscriptionTime) external onlyOwner {
        subscriptionTime = _subscriptionTime;
    }
}
