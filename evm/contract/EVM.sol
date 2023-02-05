// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EVM {
    constructor() {
        
    }



    function f() public {
        assembly{
            function allocate(length) -> pos {
                pos := mload(0x40)
                mstore(0x40, add(pos, length))
            }
            let free_memoey_pointer  := allocate(64)

            function f() -> a, b { }
            let cc, dd := f() 

            mstore(0x80, add(mload(0x80), 3))
            // 3 0x80 mload add 0x80 mstore
        }
    }

    function e(uint n, uint value) public {
        for(uint i=0; i<n; i++){
            value = 2*value;
        }
        // return value;

        assembly{
            for{  let i := 0} lt(i, n) { i := add(i, 1)}{
                value := mul(2, value)
            }
            mstore(0x0, value)
            return(0x0, 32)
        }

        assembly{
            let x := 0
            let i := 0
            for{} lt(i, 0x100){} {
                x := add(x, mload(i))
                i := add(i, 0x20)
            }
        }

        assembly{
            if slt(n, 0) { n := sub(0, n)}
            if eq(n, 1)  { revert(0, 0)  }
        }

        assembly{
            let x := 0
            switch calldataload(4)
            case 0 {  x := calldataload(0x24) }
            default {  x := calldataload(0x44) }
            sstore(0, div(x, 2))
        }
    }

    function d() public pure{
        uint b = 5;

        assembly{
            let x := add(2, 3)
            let y := 10
            let z := add(x,y)
        }

        assembly{
            let x := add(2, 3)
            let y := mul(x, b)
        }
    }

    function c() public{
        assembly{
            let x := 3
            {
                let y := x 
            }

            {
                let z := y 
            }
        }
    }

    function b(uint slength)  public {
        assembly{
            let x
            x := 4
            let f := 7
            let y := add(f, 3)
            let z := add(keccak256(0x0, 0x20), div(slength, 32))
            let n 
            let aa := 0x123
            let bb := 42
            let cc := "hello world"
            let dd := "hello world hello world hello world hello world"
        }
    }

    function a(uint x, uint y) public pure returns (uint) {
        assembly {
            let result := add(x, y) // let    :=  
            mstore(0x00, result)
            return(0x00, 32)
        }
    }
}