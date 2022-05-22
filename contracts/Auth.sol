// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

contract Auth {
    address private _admin;

    constructor(address deployer) {
        _admin = deployer;
    }

    function isAdmin(address user) public view returns (bool) {
        return user == _admin;
    }
}
