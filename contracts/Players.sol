// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./libraries/DogLib.sol";

contract Players is ERC20 {

  constructor() ERC20("Player ID", "REP") {
    
  }

}
