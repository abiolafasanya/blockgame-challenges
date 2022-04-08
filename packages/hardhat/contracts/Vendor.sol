// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import './YourToken.sol';

contract Vendor is Ownable{
  YourToken public yourToken;
  
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }
  event SellTokens(address indexed seller, uint256 amountOfTokens, uint256 amountOfETH);
  event BuyTokens(address indexed buyer, uint256 amountOfETH, uint256 amountOfTokens);

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable{

    require(msg.value > 0, "You need to send some ether"); 
    uint256 amountTobuy = msg.value * tokensPerEth; 

    yourToken.transfer(msg.sender, amountTobuy); 
    emit BuyTokens(msg.sender, msg.value, amountTobuy); 
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() public onlyOwner{
    require(address(this).balance > 0, "You don't have enough ether to withdraw"); // check if the owner has enough ether
    (bool taken,) = msg.sender.call{value: address(this).balance}(""); 
    require(taken, "withdrawal unsuccessful"); // check if the transfer was successful
  }

  // ToDo: create a sellTokens() function:
    function sellTokens(uint256 amountToken) public {
      uint256 balances = yourToken.balanceOf(msg.sender);
      require(balances >= amountToken, "You don't have enough tokens to sell"); // check if the sender has enough tokens
      uint256 saleEth = amountToken/tokensPerEth;
      yourToken.transferFrom(msg.sender, address(this), amountToken);
      (bool sold, ) = msg.sender.call{value: saleEth}("");
      require(sold, "sale unsuccessful");
      emit SellTokens(msg.sender, amountToken, saleEth);
  }
}