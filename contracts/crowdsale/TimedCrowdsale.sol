//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Crowdsale.sol";

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
abstract contract TimedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;

    
    event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);

   
    modifier onlyWhileOpen {
        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }

    
    constructor (uint256 openingTime_, uint256 closingTime_) 
    {
        require(openingTime_ >= block.timestamp, "TimedCrowdsale: opening time is before current time");
        require(closingTime_ > openingTime_, "TimedCrowdsale: opening time is not before closing time");

        _openingTime = openingTime_;
        _closingTime = closingTime_;
    }

    
    function openingTime() public view returns (uint256) {
        return _openingTime;
    }

    
    function closingTime() public view returns (uint256) {
        return _closingTime;
    }

    
    function isOpen() public view returns (bool) {
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    
    function hasClosed() public view returns (bool) {
        return block.timestamp > _closingTime;
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal virtual override onlyWhileOpen view {
        super._preValidatePurchase(beneficiary, weiAmount);
    }

    
    function _extendTime(uint256 newClosingTime) internal {
        require(!hasClosed(), "TimedCrowdsale: already closed");
        require(newClosingTime > _closingTime, "TimedCrowdsale: new closing time is before current closing time");

        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
        _closingTime = newClosingTime;
    }
}