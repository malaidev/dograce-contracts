// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./DogNFT.sol";
import "./libraries/DogLib.sol";

contract Breeding {

  constructor() {

  }

  DogNFT public dog;
  mapping(uint256 => bool) public isBreeding;
  mapping(uint256 => uint256) public breedEnded;

  function babyMake(
    uint256 maleID,
    uint256 femaleID,
    DogLib.DogBaseInfo memory maleBase,
      DogLib.DogBaseInfo memory femaleBase,
      DogLib.DogTrait memory maleTrait,
      DogLib.DogTrait memory femaleTrait,
      DogLib.DogBreedInfo memory maleBreed,
      DogLib.DogBreedInfo memory femaleBreed,
      string memory name, 
      uint256 id) public {
    require(isBreeding[maleID] == false && isBreeding[femaleID] == false, "Cannot breed!");
    require((block.timestamp - breedEnded[maleID]) > 5184000 && (block.timestamp - breedEnded[femaleID]) > 5184000, "Cannot breed!");
    require(
      maleBase.parent0 != femaleBase.parent0 && 
      maleBase.parent1 != femaleBase.parent1 &&
      maleBase.parent1 != femaleBase.id && 
      maleBase.id      != femaleBase.parent0,
      "Your dogs can not breed.");
    isBreeding[maleID] = true;
    isBreeding[femaleID] = true;
    breedEnded[maleID] = block.timestamp;
    breedEnded[femaleID] = block.timestamp;
    DogLib.DogBreedInfo memory offSpringBreed;
    DogLib.DogTrait memory offSpringTrait;
    DogLib.DogBaseInfo memory offSpringBase;
    if(DogLib.chance(50)) offSpringBase.gender = true;
    else offSpringBase.gender = false;

    if(DogLib.chance(50)) offSpringBreed.breedSuccessRate = (maleBreed.breedSuccessRate+femaleBreed.breedSuccessRate) / 2 + 2;
    else {
      if(DogLib.chance(50)) offSpringBreed.breedSuccessRate = (maleBreed.breedSuccessRate+femaleBreed.breedSuccessRate) / 2;
      else offSpringBreed.breedSuccessRate = (maleBreed.breedSuccessRate+femaleBreed.breedSuccessRate) / 2 - 2;
    }

    offSpringBase.parent0 = maleBase.id;
    offSpringBase.parent1 = femaleBase.id;
    offSpringBase.name = name;
    offSpringBase.id = id;

    if(DogLib.chance(50)) offSpringTrait.agility = (maleTrait.agility+femaleTrait.agility) / 2 + 2;
    else {
      if(DogLib.chance(50)) offSpringTrait.agility = (maleTrait.agility+femaleTrait.agility) / 2;
      else offSpringTrait.agility = (maleTrait.agility+femaleTrait.agility) / 2 - 2;
    }

    if(DogLib.chance(50)) offSpringTrait.agility = (maleTrait.agility+femaleTrait.agility) / 2 - 2;
    else {
      if(DogLib.chance(50)) offSpringTrait.agility = (maleTrait.agility+femaleTrait.agility) / 2;
      else offSpringTrait.agility = (maleTrait.agility+femaleTrait.agility) / 2 + 2;
    }

    if(DogLib.chance(50)) offSpringTrait.stamina = (maleTrait.stamina+femaleTrait.stamina) / 2 - 2;
    else {
      if(DogLib.chance(50)) offSpringTrait.stamina = (maleTrait.stamina+femaleTrait.stamina) / 2;
      else offSpringTrait.stamina = (maleTrait.stamina+femaleTrait.stamina) / 2 + 2;
    }

    offSpringTrait.health = 100;

    if(DogLib.chance(50)) offSpringTrait.luck = (maleTrait.luck+femaleTrait.luck) / 2 - 2;
    else {
      if(DogLib.chance(50)) offSpringTrait.luck = (maleTrait.luck+femaleTrait.luck) / 2;
      else offSpringTrait.luck = (maleTrait.luck+femaleTrait.luck) / 2 + 2;
    }

    if(DogLib.strcmp(maleBreed.breed, femaleBreed.breed))
      offSpringBreed.breed = maleBreed.breed;
    else 
      offSpringBreed.breed = "CrossBreed";
    dog.mint(msg.sender, offSpringTrait, offSpringBase, offSpringBreed);
  }
}