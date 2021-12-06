// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./DogNFT.sol";
import "./libraries/DogLib.sol";

contract Breeding {

  constructor() {

  }

  DogNFT public dog;

  function babyMake(DogLib.DogInfo memory male, DogLib.DogInfo memory female, string memory name, uint256 id) public {
    require(
      male.parent0 != female.parent0 && 
      male.parent1 != female.parent1 &&
      male.parent1 != female.id && 
      male.id      != female.parent0,
      "Your dogs can not breed.");
    DogLib.DogInfo memory offSpring;
    if(DogLib.chance(50)) offSpring.gender = true;
    else offSpring.gender = false;

    if(DogLib.chance(50)) offSpring.breedSuccessRate = (male.breedSuccessRate+female.breedSuccessRate) / 2 + 2;
    else {
      if(DogLib.chance(50)) offSpring.breedSuccessRate = (male.breedSuccessRate+female.breedSuccessRate) / 2;
      else offSpring.breedSuccessRate = (male.breedSuccessRate+female.breedSuccessRate) / 2 - 2;
    }

    //offSpring.id = DogNFT.dogs.length;
    offSpring.parent0 = male.id;
    offSpring.parent1 = female.id;
    offSpring.name = name;
    offSpring.id = id;

    if(DogLib.chance(50)) offSpring.agility = (male.agility+female.agility) / 2 + 2;
    else {
      if(DogLib.chance(50)) offSpring.agility = (male.agility+female.agility) / 2;
      else offSpring.agility = (male.agility+female.agility) / 2 - 2;
    }

    if(DogLib.chance(50)) offSpring.agility = (male.agility+female.agility) / 2 - 2;
    else {
      if(DogLib.chance(50)) offSpring.agility = (male.agility+female.agility) / 2;
      else offSpring.agility = (male.agility+female.agility) / 2 + 2;
    }

    if(DogLib.chance(50)) offSpring.stamina = (male.stamina+female.stamina) / 2 - 2;
    else {
      if(DogLib.chance(50)) offSpring.stamina = (male.stamina+female.stamina) / 2;
      else offSpring.stamina = (male.stamina+female.stamina) / 2 + 2;
    }

    offSpring.health = 100;

    if(DogLib.chance(50)) offSpring.luck = (male.luck+female.luck) / 2 - 2;
    else {
      if(DogLib.chance(50)) offSpring.luck = (male.luck+female.luck) / 2;
      else offSpring.luck = (male.luck+female.luck) / 2 + 2;
    }

    if(DogLib.strcmp(male.breed, female.breed))
      offSpring.breed = male.breed;
    else 
      offSpring.breed = "CrossBreed";
    dog.mint(msg.sender, offSpring);
  }
}