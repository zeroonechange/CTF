// SPDX-LICENSE: UNLICENSED  
pragma solidity ^0.8.0;

contract DeployedContract {
  uint public result = 0;

  function add(uint256 input) public {
    result = result + input;
  }
}

contract CallerContract {
  DeployedContract deployed_contract;

  constructor(DeployedContract deployedContract_) {
    deployed_contract = deployedContract_;
  }

  // see examples below of different types  
  // of low level call  


  function g(uint256 input) public{
    function (uint256) external functionToCall = deployed_contract.add;
    bytes memory calldataPayload = abi.encodeCall(functionToCall, input);
    (bool success, ) = address(deployed_contract).call(calldataPayload); 
  }

  function f(uint256 input) public{
    bytes memory calldataPayload = abi.encodeWithSelector(deployed_contract.add.selector, input);
    (bool success, ) = address(deployed_contract).call(calldataPayload); 
  }

  function e(uint256 input) public{
    bytes memory calldataPayload = abi.encodeWithSelector(0x1003e2d2, input);
    (bool success, ) = address(deployed_contract).call(calldataPayload); 
  }

  function d(uint256 input) public{
    bytes memory calldataPayload = abi.encodeWithSignature("add(uint256)", input);
    (bool success, ) = address(deployed_contract).call(calldataPayload); 
  }

  function c(uint256 input) public{
    bytes memory calldataPayload = abi.encodePacked(bytes4(keccak256("add(uint256)")), input);
    (bool success, ) = address(deployed_contract).call(calldataPayload); 
  }

  function b() public{
    bytes memory calldataPayload = hex"ffffffffffffffffffffffffffffffffffff";
    (bool success, ) = address(deployed_contract).call(calldataPayload); 
  }

  function a() public{
    bytes memory calldataPayload = "0xffffffffffffffffffffffffffffffffffff";
    (bool success, ) = address(deployed_contract).call(calldataPayload); 
  }


}




