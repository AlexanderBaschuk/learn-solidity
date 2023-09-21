// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

contract Salary {
    mapping(address => uint) public salaryInWei;

    function changeSalary(address _employee, uint _salaryInWei) external {
        salaryInWei[_employee] = _salaryInWei;
    }
}
