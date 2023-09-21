// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

contract DevForum {
    address owner;
    uint256 public initialValue;
    uint256 private mutableValue;
    string storedText = "Hello world";
    mapping(address => uint256) public mappingValues;
    mapping(address => uint256) public funds;

    constructor(uint256 _initialValue) {
        owner = msg.sender;
        initialValue = _initialValue;
    }

    function setMutableValue(uint256 _value) public {
        mutableValue = _value;
    }

    function getMutableValue() public view returns(uint256) {
        return mutableValue;
    }

    function getSum() public view returns(uint256) {
        return mutableValue + initialValue;
    }

    function setMappingValue(uint256 _value) public {
        mappingValues[msg.sender] += _value;
    }

    function deposit() public payable {
        funds[msg.sender] += msg.value;
    }

    function withdraw(uint256 _value) public {
        require(funds[msg.sender] >= _value, "Insufficient funds");

        payable(msg.sender).transfer(_value);

        funds[msg.sender] -= _value;
    }

    function fibonacci(uint256 _value) public pure returns(uint256) {
        if (_value <= 2) {
            return 1;
        }

        uint256 prev = 1;
        uint256 current = 1;
        uint256 temp;

        for (uint256 i = 3; i <= _value; i++) {
            temp = current;
            current = current + prev;
            prev = temp;
        }

        return current;
    }

    // calldata: special data location that contains the function arguments. Immutable.
    // memory: the lifetime is limited to an external function call. Mutable.
    // storage: the location where the state variables are stored, the lifetime is limited to the lifetime of a contract
    // https://docs.soliditylang.org/en/v0.8.12/types.html#data-location
    function workWithStrings(string memory memoryString, string calldata calldataString) public returns(string memory) {
        // memoryString = "abc"; - OK
        // calldataString = "abc"; - ERROR

        storedText = string.concat(storedText, "!");
        
        return string.concat(memoryString, " ", calldataString);
    }

    fallback() external payable {
        revert("Unknown function was called");
    }

    receive() external payable {
        funds[owner] += msg.value;
    }
}


