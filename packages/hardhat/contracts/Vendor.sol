pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
     event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        uint256 amountOfTokens = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, amountOfTokens);
        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }

    // Withdraw function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Failed to withdraw");
    }

    // SellTokens function with approve pattern
    event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);
    
    function sellTokens(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        uint256 ethAmount = amount / tokensPerEth;
        require(address(this).balance >= ethAmount, "Insufficient ETH in vendor");
        
        // Transfer tokens from user to vendor
        yourToken.transferFrom(msg.sender, address(this), amount);
        
        // Send ETH to user
        (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        require(success, "Failed to send ETH");
        
        emit SellTokens(msg.sender, amount, ethAmount);
    }
}
