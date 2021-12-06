// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FoodNFT is ERC1155, Ownable{

  struct FoodInfo {
    string name;
    uint256 uses;
    uint256 stamina;
    uint256 weight;
  }

  // Mapping from food ID to food Info
  mapping(uint256 => FoodInfo) public _foods;

  using Counters for Counters.Counter;

  Counters.Counter private _tokenIdCounter;

  constructor() ERC1155("") {
  }
  function mint(address _to, string memory _name, uint256 _uses, uint _stamina, string memory _tokenURI, uint256 amount) public onlyOwner{
    bytes memory data;
    FoodInfo memory food;
    food.name = _name;
    food.uses = _uses;
    food.stamina = _stamina;
    uint256 _newFoodId = _tokenIdCounter.current();
    _foods[_newFoodId] = food;
    _mint(_to, _newFoodId, amount, data);
    _tokenIdCounter.increment();
    _setURI(_tokenURI);
  }
  function getFoodStamina( uint foodID ) public view returns (uint256) {
    uint256 _stamina = _foods[foodID].stamina;
    return _stamina;
  }
  function getFoodWeight( uint foodID ) public view returns (uint256) {
    uint256 _weight = _foods[foodID].weight;
    return _weight;
  }
  function getUses( uint foodID ) public view returns (uint256) {
    uint256 _uses = _foods[foodID].uses;
    return _uses;
  }
}
