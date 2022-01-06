// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DogLib {

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct DogStorage {
        uint256 seed;
    }
    struct DogTrait {
        uint256 agility;
        uint256 weight;
        uint256 stamina;
        uint256 health;
        uint256 luck;
    }
    struct DogBaseInfo {
        bool gender;
        uint256 parent0;    //male
        uint256 parent1;    //female
        uint256 id;
        string name;
    }
    struct DogBreedInfo {
        string breed;   //kind of the dog
        uint256 breedSuccessRate;
        uint256 breedStart;
        uint256 breedEnd;
    }

    struct extraTrait {     //when used comsumes
        uint256 agility;
        uint256 weight;
        uint256 stamina;
        uint256 luck;
        uint256 trainSuccessRate;
    }
    struct playerTrait {
        uint256 strenght;
        uint256 agility;
        uint256 stamina;
        uint256 endurance;
        uint256 dexterity;
        uint256 intelligence;
        uint256 charisma;
        uint256 perception;
        uint256 luck;
    }

    function dogStorage() internal pure returns(DogStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function rand() internal returns(uint256) {
        DogStorage storage ds = dogStorage();
        ds.seed = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, ds.seed)));
        return ds.seed;
    }

    function randInRange(uint256 min, uint256 max) internal returns(uint256) {
        require(min < max, "DogLib: Invalid range of random");

        uint256 randval = rand();
        uint256 range = max - min;

        return (randval % range + min);
    }

    function chance(uint256 percent) internal returns(bool) {
        require(percent <= 100, "DogLib: Invalid percent of chance");

        uint256 randval = randInRange(1, 100);

        return (randval <= percent);
    }

    function strcmp(string memory str1, string memory str2) internal pure returns(bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    function sortDESC(uint256[] memory spendTime) internal pure returns(uint256[] memory) {
        uint256[] memory result;
        uint256 length = spendTime.length;
        for(uint256 i = 0; i < length; i++) {
            result[i] = i;
        }
        for(uint256 i = 0; i < length-1; i++) {
            for(uint256 j = i + 1; j < length; j++) {
                if(spendTime[i] > spendTime[j]) {
                    uint256 temp;
                    temp = result[i];
                    result[i] = result[j];
                    result[j] = temp;
                }
            }
        }
        return result;
    }

    function pickMax(uint256[] memory result) internal pure returns(uint256) {
        uint256 winner = 0;
        for(uint256 index = 0; index < result.length; index++) {
            if(result[index] > result[winner])
                winner = index;
        }
        return winner;
    }
}