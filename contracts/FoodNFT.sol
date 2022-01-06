// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FoodNFT is ERC1155, Ownable{

  struct FoodInfo {
    string name;
    uint256 id;
    uint256 uses;
    uint256[] stamina;
    uint256[] agility;
    uint256[] weight;
    uint256[] luck;
    uint256[] trainSuccessRate;
  }

  // Mapping from food ID to food Info
  mapping(uint256 => FoodInfo) public _foods;

  constructor() ERC1155("") {
  }
  function mint(address _to, 
    string memory _name, 
    uint256 _id,
    uint256 _uses, 
    uint256[] memory _stamina, 
    uint256[] memory _agility,
    uint256[] memory _weight, 
    uint256[] memory _luck,
    uint256[] memory _trainSuccessRate,
    string memory _tokenURI, 
    uint256 amount) public onlyOwner{
      bytes memory data;
      FoodInfo memory food;
      food.name = _name;
      food.uses = _uses;
      food.stamina = _stamina;
      food.agility = _agility;
      food.weight = _weight;
      food.luck = _luck;
      food.trainSuccessRate = _trainSuccessRate;
      _foods[_id] = food;
      _mint(_to, _id, amount, data);
      _setURI(_tokenURI);
  }

  function getFoodAgility(uint256 foodID, uint256 amount) public view returns (uint256) {
    uint256[] memory _agility = _foods[foodID].agility;
    return _agility[amount-1];
  }

  function getFoodStamina(uint256 foodID, uint256 amount) public view returns (uint256) {
    uint256[] memory _stamina = _foods[foodID].stamina;
    return _stamina[amount-1];
  }

  function getFoodWeight(uint foodID, uint256 amount) public view returns (uint256) {
    uint256[] memory _weight = _foods[foodID].weight;
    return _weight[amount-1];
  }
  
  function getFoodLuck(uint foodID, uint256 amount) public view returns (uint256) {
    uint256[] memory _luck = _foods[foodID].luck;
    return _luck[amount-1];
  }

  function getFoodTrainSuccessRate(uint foodID, uint256 amount) public view returns (uint256) {
    uint256[] memory _trainSuccessRate = _foods[foodID].trainSuccessRate;
    return _trainSuccessRate[amount-1];
  }
  function getUses(uint foodID) public view returns (uint256) {
    uint256 _uses = _foods[foodID].uses;
    return _uses;
  }
}
