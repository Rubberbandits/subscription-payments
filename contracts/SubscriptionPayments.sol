//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

error SubscriberNotAdded(string reason);

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

		(bool success) = addSubscriber(_msgSender());
		if (!success) {
			revert SubscriberNotAdded("addSubscriber failed");
		}

        emit PaymentReceived(_msgSender(), msg.value);
    }

	// Internal
	function addSubscriber(address subscriber) internal returns (bool success) {
		if (subscriptions[subscriber] < block.timestamp) {
            require(subscriptionKeys.length < maxSubscriptions, "No slots");
        }

        subscriptions[subscriber] = block.timestamp + subscriptionTime;
        subscriptionKeys.push(subscriber);

		return true;
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

	function giveSubscriber(address subscriber) external onlyOwner {
		(bool success) = addSubscriber(subscriber);
		if (!success) {
			revert SubscriberNotAdded("addSubscriber failed");
		}
	}
}
