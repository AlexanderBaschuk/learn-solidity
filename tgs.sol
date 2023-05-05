// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

contract TgsVariables {
    uint256 public initialValue;
    uint256 private mutableValue;
    mapping(address => uint256) public mappingValues;
    mapping(address => uint256) public funds;

    constructor(uint256 _initialValue) {
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

    function withdrawT(uint256 _value) public {
        require(funds[msg.sender] >= _value, "Insufficient funds");

        funds[msg.sender] -= _value;

        payable(msg.sender).transfer(_value);
    }

    function withdrawC(uint256 _value) public {
        require(funds[msg.sender] >= _value, "Insufficient funds");

        funds[msg.sender] -= _value;
        
        (bool success, ) = payable(msg.sender).call{value: _value}("");
        require(success,"Failed to send Eth!");
    }
}


