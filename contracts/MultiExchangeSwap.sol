// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

contract MultiExchangeSwap is Ownable {

    function swapTokens(uint256 amountIn, address tokenOne, address tokenTwo, address routerOneAddress, address routerTwoAddress) public payable onlyOwner {

        address[] memory path = new address[](2);
        path[0] = tokenOne;
        path[1] = tokenTwo;

        address[] memory reversedPath = new address[](2);
        reversedPath[0] = tokenTwo;
        reversedPath[1] = tokenOne;

        IUniswapV2Router02 routerOne = IUniswapV2Router02(routerOneAddress);
        IERC20 IERC20TokenOne = IERC20(tokenOne);
        IERC20TokenOne.approve(address(routerOne), amountIn);

        uint[] memory firstSwapAmounts = routerOne.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp + 300
        );

        IUniswapV2Router02 routerTwo = IUniswapV2Router02(routerTwoAddress);
        IERC20 IERC20TokenTwo = IERC20(tokenTwo);
        IERC20TokenTwo.approve(address(routerTwo), firstSwapAmounts[1]);

        uint[] memory secondSwapAmounts = routerTwo.swapExactTokensForTokens(
            firstSwapAmounts[1],
            amountIn,
            reversedPath,
            address(this),
            block.timestamp + 300
        );

    }

    function withdraw(address _tokenAddress) public onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    receive() external payable {}
}