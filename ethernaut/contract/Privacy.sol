// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Privacy {

  bool public locked = true;
  uint256 public ID = block.timestamp;
  uint8 private flattening = 10;
  uint8 private denomination = 255;
  uint16 private awkwardness = uint16(block.timestamp);
  bytes32[3] private data;

  constructor(bytes32[3] memory _data) {
    data = _data;
  }
  
  function unlock(bytes16 _key) public {
    require(_key == bytes16(data[2]));
    locked = false;
  }

  /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
  */
}

/**
	await web3.eth.getStorageAt(instance, 0);
	await web3.eth.getStorageAt(instance, 1);
	await web3.eth.getStorageAt(instance, 2);
	await web3.eth.getStorageAt(instance, 3);
	await web3.eth.getStorageAt(instance, 4);
	await web3.eth.getStorageAt(instance, 5);    -- 这就是 data[2]存放的区域  
	一共32个字节  拿出前一半  
	0xc607037c447e12c2a7d087136d62dbe6224859c14e90c3dffa60eb0c933694e3 
	await contract.unlock('0xc607037c447e12c2a7d087136d62dbe6'); 
 */