// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DogNFT.sol";
import "./FoodNFT.sol";
import "./libraries/DogLib.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Race {

  using Counters for Counters.Counter;
  mapping(uint256 => bool) isRaceExist;

  address[] public dailyParticipant;
  address[] public tourParticipant;
  address[] public championParticipant;
  mapping(uint256 => uint256) count;  //how many participants per each race
  mapping(uint256 => mapping(uint256 => uint256)) players;  //raceType => id => dogID
  mapping(uint256 => mapping(uint256 => DogLib.DogBaseInfo)) playerBase;   //racetype => dogID => ...
  mapping(uint256 => mapping(uint256 => address)) dogOwners;  //raceType => dogID => ownerAdress
  mapping(uint256 => mapping(uint256 => DogLib.extraTrait)) extra; //raceType => dogID => extraTrait
  mapping(uint256 => uint256) extraAgility; //dogID => extraAgility      #when good event occurs during race
  uint256[] public dDogID;  //dogIDs of daily race players
  uint256[] public tDogID;  //dogIDs of tournament race players
  uint256[] public cDogID;  //dogIDs of champaign race players
  uint256[3] raceRound;  //daily:1   tournament:3    championShip:6  constant
  uint256[3] requiredStam;  //required stamina to join in the race   daily:15   tournament:20    championShip:25
  mapping(uint256 => uint256) currentRound;   //
  DogLib.DogTrait[] dTrait; //trait of daily race players
  DogLib.DogTrait[] tTrait; //trait of tournament race players
  DogLib.DogTrait[] cTrait; //trait of champaign race players
  DogNFT dog;
  //  racetype=0 : dailyRace  1: tournament 2: championShip
  struct dailyResult {
    uint256 dogID;
    uint256 ability;
  }

  struct tournamentResult {
    uint256 dogID;
    uint256 ability;
  }

  struct champignResult {
    uint256 dogID;
    uint256 ability;
  }

  dailyResult[] dResult;
  tournamentResult[] tResult;
  champignResult[] cResult;

  constructor() {
    raceRound[0] = 1;
    raceRound[1] = 3;
    raceRound[2] = 6;
    requiredStam[0] = 15;
    requiredStam[1] = 20;
    requiredStam[2] = 25;
  }

  function participate(uint256 dogID, uint256 raceType) public {
    require(isRaceExist[raceType] == true, "No race organized");
    require(count[raceType]<12, "Full participants");
    require(dog.getDogStamina(dogID) >= requiredStam[raceType], "Your dog is too tired to race");

    if(raceType == 0) { 
      dDogID.push(dogID);
      dTrait.push(dog.getDogTrait(dogID));
    }
    else if(raceType == 1) { 
      tDogID.push(dogID); 
      tTrait.push(dog.getDogTrait(dogID)); 
    }
    else { 
      cDogID.push(dogID); 
      cTrait.push(dog.getDogTrait(dogID)); 
    }

    uint256 index;
    index = count[raceType];
  //  players[raceType][count] = dogID;
    count[raceType]++;
  }

  function organizeRace(uint256 raceType) public {
    isRaceExist[raceType] = true;
  }

  function startRace(uint256 raceType) public {
    require(count[raceType] >= 10, "Not enough players");
    raceMain(raceType);
    
  }

  function raceMain(uint256 raceType) public {
    require(currentRound[raceType] < raceRound[raceType], "Race over");
    uint256[] memory dTotalResult;
    uint256[] memory tTotalResult;
    uint256[] memory cTotalResult;
    uint256 dWinner;
    uint256 tWinner;
    uint256 cWinner;
    if(raceType == 0) {
      for( uint256 index = 0; index < dTrait.length; index++ ) {
        if(DogLib.chance(dTrait[index].luck)) getAgility(index);
        else getInjured(raceType, index);
        dTotalResult[index] = (dTrait[index].agility + extraAgility[index]) * dTrait[index].stamina * dTrait[index].health / dTrait[index].weight;
        extraAgility[index] = 0;
      }
      for( uint256 index = 0; index < dTrait.length; index++ ) {
        if(DogLib.chance(dTrait[index].luck)) getAgility(index);
        else getInjured(raceType, index);
        dTotalResult[index] = dTotalResult[index] + (dTrait[index].agility + extraAgility[index]) * dTrait[index].stamina * dTrait[index].health / dTrait[index].weight;
        extraAgility[index] = 0;
      }
      for( uint256 index = 0; index < dTrait.length; index++ ) {
        if(DogLib.chance(dTrait[index].luck)) getAgility(index);
        else getInjured(raceType, index);
        dTotalResult[index] = dTotalResult[index] + (dTrait[index].agility + extraAgility[index]) * dTrait[index].stamina * dTrait[index].health / dTrait[index].weight;
        extraAgility[index] = 0;
      }
      dWinner = dDogID[DogLib.pickMax(dTotalResult)];
    }

    else if(raceType == 1) {
      for( uint256 index = 0; index < tTrait.length; index++ ) {
        if(DogLib.chance(tTrait[index].luck)) getAgility(index);
        else getInjured(raceType, index);
        tTotalResult[index] = (tTrait[index].agility + extraAgility[index]) * tTrait[index].stamina * tTrait[index].health / tTrait[index].weight;
        extraAgility[index] = 0;
      }
      for( uint256 index = 0; index < tTrait.length; index++ ) {
        if(DogLib.chance(tTrait[index].luck)) getAgility(index);
        else getInjured(raceType, index);
        tTotalResult[index] = tTotalResult[index] + (tTrait[index].agility + extraAgility[index]) * tTrait[index].stamina * tTrait[index].health / tTrait[index].weight;
        extraAgility[index] = 0;
      }
      for( uint256 index = 0; index < tTrait.length; index++ ) {
        if(DogLib.chance(tTrait[index].luck)) getAgility(index);
        else getInjured(raceType, index);
        tTotalResult[index] = tTotalResult[index] + (tTrait[index].agility + extraAgility[index]) * tTrait[index].stamina * tTrait[index].health / tTrait[index].weight;
        extraAgility[index] = 0;
      }
      tWinner = tDogID[DogLib.pickMax(tTotalResult)];
    }

    else {
      for( uint256 index = 0; index < cTrait.length; index++ ) {
        if(DogLib.chance(cTrait[index].luck)) getAgility(index);
        else getInjured(raceType, index);
        cTotalResult[index] = (cTrait[index].agility + extraAgility[index]) * cTrait[index].stamina * cTrait[index].health / cTrait[index].weight;
        extraAgility[index] = 0;
      }
      for( uint256 index = 0; index < cTrait.length; index++ ) {
        if(DogLib.chance(cTrait[index].luck)) getAgility(index);
        else getInjured(raceType, index);
        cTotalResult[index] = cTotalResult[index] + (cTrait[index].agility + extraAgility[index]) * cTrait[index].stamina * cTrait[index].health / cTrait[index].weight;
        extraAgility[index] = 0;
      }
      for( uint256 index = 0; index < cTrait.length; index++ ) {
        if(DogLib.chance(cTrait[index].luck)) getAgility(index);
        else getInjured(raceType, index);
        cTotalResult[index] = cTotalResult[index] + (cTrait[index].agility + extraAgility[index]) * cTrait[index].stamina * cTrait[index].health / cTrait[index].weight;
        extraAgility[index] = 0;
      }
      cWinner = cDogID[DogLib.pickMax(cTotalResult)];
    }
  }

  function getAgility(uint256 index) public {
    extraAgility[index] = 20;
  }

  function getInjured(uint256 raceType, uint256 index) public {
    uint256 dogID;
    if(raceType == 0) dogID = dDogID[index];
    else if(raceType == 1) dogID = tDogID[index];
    else dogID = cDogID[index]; 
    //dog.dogTrait[dogID].health = dog.dogTrait[dogID].health - 10;
    dog.decreaseHealth(dogID);
    if(raceType == 0)
      dTrait[index].health = dTrait[index].health - 10;
    else if(raceType == 1)
      tTrait[index].health = tTrait[index].health - 10;
    else
      cTrait[index].health = cTrait[index].health - 10;
  }
}