//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./crowdsale/Crowdsale.sol";
import "./crowdsale/CappedCrowdsale.sol";
import "./crowdsale/TimedCrowdsale.sol";
import "./utils/WhitelistedRoles.sol";


contract BTEMSale is Crowdsale, CappedCrowdsale, TimedCrowdsale, WhitelistedRole, Ownable{
    using SafeMath for uint256;

    bool public paused;
    uint256 public minContrib = 300 * 10 ** 18;
    uint256 public maxContrib = 3000 * 10 ** 18;

    modifier notPaused(){
        require(!paused, "The sale is paused");
        _;
    }

    constructor(
        uint256 rate_, 
        address payable wallet_, 
        IERC20 token_,
        uint256 openingTime_,
        uint256 closingTime_,
        uint256 cap_
    )
    Crowdsale(rate_, wallet_, token_)
    WhitelistedRole()
    CappedCrowdsale(cap_)
    TimedCrowdsale(openingTime_, closingTime_)
    Ownable()
    {
        paused = false;
    }

    /**
        @dev Function to pause the sale
    */
    function pauseSale() public onlyOwner{
        paused = true;
    }


    /**
        @dev Function to unpause the sale
    */
    function unpauseSale() public onlyOwner{
        paused = false;
    }


    function setMinContrib(uint256 amount) public onlyOwner {
        require(block.timestamp < openingTime(), "Too late");
        minContrib = amount;
    }


    function setMaxContrib(uint256 amount) public onlyOwner {
        require(block.timestamp < openingTime(), "Too late");
        maxContrib = amount;
    }


    function _preValidatePurchase(address beneficiary, uint256 weiAmount) 
        internal 
        view 
        override(
            Crowdsale, 
            CappedCrowdsale, 
            TimedCrowdsale
        ) 
        onlyWhileOpen 
        notPaused
    {
        super._preValidatePurchase(beneficiary, weiAmount);
        require(weiAmount >= minContrib && weiAmount <= maxContrib, "weiAmount is not valid");
        require(isWhitelisted(beneficiary), "WhitelistCrowdsale: beneficiary doesn't have the Whitelisted role");
    }
}