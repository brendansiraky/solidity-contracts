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

contract TriangleSwap is Ownable {

    IUniswapV2Router02 public swapRouter;

    constructor(address _routerAddress) {
        swapRouter = IUniswapV2Router02(_routerAddress);
    }

    function swapTokens(uint256 amountIn, address[] memory path) public payable onlyOwner returns (uint outputAmount) {

        IERC20 token = IERC20(path[0]);
        token.approve(address(swapRouter), amountIn);
        // (uint[] memory amounts, uint[] memory fees)
        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, // @param - amountIN
            amountIn, // @param - amountOutMin: We ofcourse want this to be no less than the amount out.
            path, // @param - path we will talk for tha trades e.g [WBNB, CAKE, BUSD, WBNB] = 3 trades will be executed here.
            address(this), // @param - Send back to this contract
            block.timestamp + 300 // @param Current block + 5 minutes
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