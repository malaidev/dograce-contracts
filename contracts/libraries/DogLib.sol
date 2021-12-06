// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DogLib {

    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct DogStorage {
        uint256 seed;
    }

    struct DogInfo {
        bool gender; // false = female, true = male
        string breed;   // kind of the dog
        uint256 breedSuccessRate;
        string name;
        uint256 id;
        uint256 parent0; //male
        uint256 parent1; //female
        uint256 agility;
        uint256 weight;
        uint256 stamina;
        uint256 health;
        uint256 luck;
        uint256 breedStart;
        uint256 breedEnd;
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
}