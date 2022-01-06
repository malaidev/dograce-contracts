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
    uint256 luck;
  }

  struct StaminaRecord {
    uint256 lastRecordedStam;
    uint256 lastRecordedTime;
  }

  FoodNFT public food;
  mapping(uint256 => DogLib.extraTrait) public extraTrait;

  Counters.Counter private _tokenIdCounter;

  mapping(uint256 => DogLib.DogTrait) public dogTrait;
  mapping(uint256 => DogLib.DogBaseInfo) public dogBase;
  mapping(uint256 => DogLib.DogBreedInfo) public dogBreed;
  mapping(uint256 => oldDogInfo) public oldInfo;
  mapping(uint256 => StaminaRecord) public staminas;
  mapping(uint256 => bool) public istraining;   //Is this dog training now?
  mapping(uint256 => bool) public isillegal;    //Is illegal was placed on this dog?
  mapping(uint256 => bool) public trainField;   //Does this dog have a train field?
  mapping(uint256 => bool) public breedingHouse;    //Does this dog have a breeding house?

  constructor() ERC721("","") {
    
  }

  function mint(address _to,
      DogLib.DogTrait memory _trait, 
      DogLib.DogBaseInfo memory _base, 
      DogLib.DogBreedInfo memory _breed) public {

      uint256 _newDogId = _tokenIdCounter.current();
      _safeMint(_to, _newDogId);

      dogTrait[_newDogId] = _trait;
      dogBase[_newDogId] = _base;
      dogBreed[_newDogId] = _breed;

      oldInfo[_newDogId].agility = _trait.agility;
      oldInfo[_newDogId].stamina = _trait.stamina;
      oldInfo[_newDogId].health = _trait.health;
      oldInfo[_newDogId].weight = _trait.weight;
      oldInfo[_newDogId].luck = _trait.luck;

      istraining[_newDogId] = false;
      isillegal[_newDogId] = false;
      trainField[_newDogId] = false;
      breedingHouse[_newDogId] = false;
  }
  
  function feed(uint256 dogID, uint256 foodID, uint256 amount) public {

    require(food.balanceOf(msg.sender, foodID) >= amount, "You havn't got enough food!");
    require(!istraining[dogID] || foodID == 3, "Your dog is training now");

    extraTrait[dogID].stamina = food.getFoodStamina(foodID, amount);
    extraTrait[dogID].agility = food.getFoodAgility(foodID, amount);
    extraTrait[dogID].luck = food.getFoodLuck(foodID, amount);
    extraTrait[dogID].weight = food.getFoodWeight(foodID, amount);
    extraTrait[dogID].trainSuccessRate = food.getFoodTrainSuccessRate(foodID, amount);


    oldInfo[dogID].agility = dogTrait[dogID].agility;
    oldInfo[dogID].weight = dogTrait[dogID].weight;
    oldInfo[dogID].health = dogTrait[dogID].health;
    oldInfo[dogID].stamina = dogTrait[dogID].stamina;
    oldInfo[dogID].luck = dogTrait[dogID].luck;

    dogTrait[dogID].stamina = dogTrait[dogID].stamina + extraTrait[dogID].stamina;
    dogTrait[dogID].weight = dogTrait[dogID].weight + extraTrait[dogID].weight;
    dogTrait[dogID].agility = dogTrait[dogID].agility + extraTrait[dogID].agility;
    dogTrait[dogID].luck = dogTrait[dogID].luck + extraTrait[dogID].luck;

  }

  function setDefault(uint256 dogID) public {
    dogTrait[dogID].agility = oldInfo[dogID].agility;
    dogTrait[dogID].weight = oldInfo[dogID].weight;
    dogTrait[dogID].health = oldInfo[dogID].health;
    dogTrait[dogID].stamina = oldInfo[dogID].stamina;
    extraTrait[dogID].stamina = 0;
    extraTrait[dogID].agility = 0;
    extraTrait[dogID].luck = 0;
    extraTrait[dogID].weight = 0;
    extraTrait[dogID].trainSuccessRate = 0;
  }

  function startTrain(uint256 dogID, uint256 trainType) public {

    require(isillegal[dogID] == false || trainField[dogID] == true, "You can not enter to the train field!");
    require(!istraining[dogID], "Your dog is training now!");

    oldInfo[dogID].agility = dogTrait[dogID].agility;
    oldInfo[dogID].weight = dogTrait[dogID].weight;
    oldInfo[dogID].health = dogTrait[dogID].health;
    oldInfo[dogID].stamina = dogTrait[dogID].stamina;

    istraining[dogID] = true;

    if(trainType == 0) {    //train
      require(dogTrait[dogID].stamina >= 20, "Not enough stamina");
      if(DogLib.chance(80+extraTrait[dogID].trainSuccessRate)) {
        dogTrait[dogID].agility = dogTrait[dogID].agility + 2;
        dogTrait[dogID].weight = dogTrait[dogID].weight - 1;
      }
    }

    else if(trainType == 1) {
      require(dogTrait[dogID].stamina >= 20, "Not enough stamina");
      if(DogLib.chance(70+extraTrait[dogID].trainSuccessRate)) {
        dogTrait[dogID].agility = dogTrait[dogID].agility + 3;
        dogTrait[dogID].weight = dogTrait[dogID].weight - 1;
      }
    }

    else {
      require(dogTrait[dogID].stamina >= 20, "Not enough stamina");
      if(DogLib.chance(50+extraTrait[dogID].trainSuccessRate)) {
        dogTrait[dogID].agility = dogTrait[dogID].agility + 5;
        dogTrait[dogID].weight = dogTrait[dogID].weight - 2;
      }
    }

  }

  function endTrain(uint256 dogID) public {
    istraining[dogID] = false;

    oldInfo[dogID].agility = dogTrait[dogID].agility;
    oldInfo[dogID].weight = dogTrait[dogID].weight;
    oldInfo[dogID].health = dogTrait[dogID].health;
    oldInfo[dogID].stamina = dogTrait[dogID].stamina;
  }


  function heal(uint256 dogID) public {
    dogTrait[dogID].health = 100;
    oldInfo[dogID].health = dogTrait[dogID].health;
  }

  function getDogStamina(uint256 dogID) public view returns(uint256) {
    return dogTrait[dogID].stamina;
  }

  function getDogTrait(uint256 dogID) public view returns(DogLib.DogTrait memory) {
    return dogTrait[dogID];
  }

  function decreaseHealth(uint256 dogID) public {
    dogTrait[dogID].health = dogTrait[dogID].health - 10;
  }

  // function getDogInfo(uint256 dogID) public view returns(DogLib.DogInfo memory) {
  //   DogLib.DogInfo memory dogInfo;
  //   dogInfo.gender = dogs[dogID].gender;
  //   dogInfo.name = dogs[dogID].name;

  //   dogInfo.parent0 = dogs[dogID].parent0;
  //   dogInfo.parent1 = dogs[dogID].parent1;
  //   dogInfo.stamina = oldInfo[dogID].stamina;
  //   dogInfo.weight = oldInfo[dogID].weight;
  //   dogInfo.agility = oldInfo[dogID].agility;
  //   dogInfo.health = oldInfo[dogID].health;
  //   dogInfo.luck = dogs[dogID].luck;

  //   return dogInfo;
  // }
}
