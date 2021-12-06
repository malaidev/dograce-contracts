// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./FoodNFT.sol";
import "./libraries/DogLib.sol";

contract DogNFT is ERC721 {

  using Counters for Counters.Counter;

  struct oldDogInfo {   //info has to be returned to front
    uint256 agility;
    uint256 weight;
    uint256 stamina;
    uint256 health;
  }

  struct StaminaRecord {
    uint256 lastRecordedStam;
    uint256 lastRecordedTime;
  }

  FoodNFT public food;

  Counters.Counter private _tokenIdCounter;

  mapping(uint256 => DogLib.DogInfo) public dogs;
  mapping(uint256 => oldDogInfo) public oldInfo;
  mapping(uint256 => StaminaRecord) public staminas;
  mapping(uint256 => bool) public istraining;   //Is this dog training now?
  mapping(uint256 => bool) public isillegal;    //Is illegal was placed on this dog?
  mapping(uint256 => bool) public trainField;   //Does this dog have a train field?
  mapping(uint256 => bool) public breedingHouse;    //Does this dog have a breeding house?

  constructor() ERC721("","") {
    
  }

  function mint(address _to, DogLib.DogInfo memory info) public {

      uint256 _newDogId = _tokenIdCounter.current();
      _safeMint(_to, _newDogId);

      dogs[_newDogId] = info;
      istraining[_newDogId] = false;
      isillegal[_newDogId] = false;
      trainField[_newDogId] = false;
      breedingHouse[_newDogId] = false;
  }
  
  function feed(uint256 dogID, uint256 foodID, uint256 amount) public {

    require(food.balanceOf(msg.sender, foodID) >= amount, "You havn't got enough food!");
    require(!istraining[dogID], "Your dog is training now");

    uint256 extraStamina = food.getFoodStamina(foodID);
    uint256 extraWeight = food.getFoodWeight(foodID);

    dogs[dogID].stamina = dogs[dogID].stamina + extraStamina * amount;
    dogs[dogID].weight = dogs[dogID].weight + extraWeight * amount;

  }

  function startTrain(uint256 dogID, uint256 trainType) public {

    require(isillegal[dogID] == false || trainField[dogID] == true, "You can not enter to the train field!");
    require(!istraining[dogID], "Your dog is training now!");

    oldInfo[dogID].agility = dogs[dogID].agility;
    oldInfo[dogID].weight = dogs[dogID].weight;
    oldInfo[dogID].health = dogs[dogID].health;
    oldInfo[dogID].stamina = dogs[dogID].stamina;

    istraining[dogID] = true;

    if(trainType == 0) {    //train
      require(dogs[dogID].stamina >= 20, "Not enough stamina");
      if(DogLib.chance(80)) {
        dogs[dogID].agility = dogs[dogID].agility + 2;
        dogs[dogID].weight = dogs[dogID].weight - 1;
      }
    }

    else if(trainType == 1) {
      require(dogs[dogID].stamina >= 20, "Not enough stamina");
      if(DogLib.chance(70)) {
        dogs[dogID].agility = dogs[dogID].agility + 3;
        dogs[dogID].weight = dogs[dogID].weight - 1;
      }
    }

    else {
      require(dogs[dogID].stamina >= 20, "Not enough stamina");
      if(DogLib.chance(50)) {
        dogs[dogID].agility = dogs[dogID].agility + 5;
        dogs[dogID].weight = dogs[dogID].weight - 2;
      }
    }

  }

  function endTrain(uint256 dogID) public {
    istraining[dogID] = false;

    oldInfo[dogID].agility = dogs[dogID].agility;
    oldInfo[dogID].weight = dogs[dogID].weight;
    oldInfo[dogID].health = dogs[dogID].health;
    oldInfo[dogID].stamina = dogs[dogID].stamina;
  }


  function heal(uint256 dogID) public {
    dogs[dogID].health = 100;
    oldInfo[dogID].health = dogs[dogID].health;
  }

  function getDogInfo(uint256 dogID) public view returns(DogLib.DogInfo memory) {
    DogLib.DogInfo memory dogInfo;
    dogInfo.gender = dogs[dogID].gender;
    dogInfo.name = dogs[dogID].name;

    dogInfo.parent0 = dogs[dogID].parent0;
    dogInfo.parent1 = dogs[dogID].parent1;
    dogInfo.stamina = oldInfo[dogID].stamina;
    dogInfo.weight = oldInfo[dogID].weight;
    dogInfo.agility = oldInfo[dogID].agility;
    dogInfo.health = oldInfo[dogID].health;
    // istraining = dogs[dogID].istraining;
    // dogInfo.isillegal = dogs[dogID].isillegal;
    dogInfo.luck = dogs[dogID].luck;

    return dogInfo;
  }
}
