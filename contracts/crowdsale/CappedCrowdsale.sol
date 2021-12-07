//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Crowdsale.sol";


abstract contract CappedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 private _cap;

    
    constructor (uint256 cap_) {
        require(cap_> 0, "CappedCrowdsale: cap is 0");
        _cap = cap_;
    }

    
    function cap() public view returns (uint256) {
        return _cap;
    }

    
    function capReached() public view returns (bool) {
        return weiRaised() >= _cap;
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal virtual override view {
        super._preValidatePurchase(beneficiary, weiAmount);
        require(weiRaised().add(weiAmount) <= _cap, "CappedCrowdsale: cap exceeded");
    }
}