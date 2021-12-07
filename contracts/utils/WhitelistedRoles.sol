//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/utils/Context.sol";

contract WhitelistedRole is Context{
    address private _whitelistedAdmin;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    mapping(address => bool) private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(_msgSender()), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    modifier onlyAdmin() {
        require(_msgSender() == _whitelistedAdmin, "msg.sender must be admin");
        _;
    }

    constructor(){
        _whitelistedAdmin = _msgSender();
    }

    

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds[account];
    }

    function addWhitelisted(address account) public onlyAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(_msgSender());
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds[account] = true;
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        delete _whitelisteds[account];
        emit WhitelistedRemoved(account);
    }
}