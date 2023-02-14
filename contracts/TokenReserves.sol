// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";

contract TokenReserves {

    IUniswapV2Factory factory;

    constructor(address _factory) {
        factory = IUniswapV2Factory(_factory);
    }

    struct Reserve {
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTimestampLast;
    }

    struct Tokens {
        address token0;
        address token1;
    }

    struct Reserves {
        address token0;
        uint reserve0;
        address token1;
        uint reserve1;
        address pairAddress;
    }

    function getPairAddresses(Tokens[] memory inputTokens) public view returns (Reserves[] memory reserves) {
        reserves = new Reserves[](inputTokens.length);
        for (uint i = 0; i < inputTokens.length; i++) {            
            address pairAddress = factory.getPair(inputTokens[i].token0, inputTokens[i].token1);
            IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
            (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = pair.getReserves();
            reserves[i].reserve0 = reserve0;
            reserves[i].reserve1 = reserve1;
            reserves[i].token0 = inputTokens[i].token0;
            reserves[i].token1 = inputTokens[i].token1;
            reserves[i].pairAddress = pairAddress;
        }
    }

    
}