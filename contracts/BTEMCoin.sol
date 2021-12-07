//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "../node_modules/@openzeppelin/contracts/utils/Context.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract BTEMCoin is IERC20, Ownable{
    using SafeMath for uint256;
    using Address for address;

    string public _name = "Besteam Coin";
    string public _symbol = "BTEM";
    uint256 public _totalSupply;

    address public marketWallet = 0xA1B75255829de9BCaE5de27ad449ddaa5dAB798C;
    uint256 public marketFee = 4;

    address public devWallet = 0x03eDE84E062aB58df13bD73Ac550B1473A38F26c;
    uint256 public devFee = 6;

    address public LPWallet = 0xF6d351EB65944369eC419560689049D68f53eA8a;
    uint256 public LPFee = 2;

    bool public takeFee;
    bool public limited;
    uint256 public maxTokensForWallet; 
    uint256 public maxTxAmount; 

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => mapping (address => uint256)) private _allowances;

    modifier withGrant(){
        require(msg.sender == devWallet || msg.sender == owner());
        _;
    }

    constructor()
    Ownable()
    {
        _mint(msg.sender, 100000000 * 10 ** 18);
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        takeFee = false;
        limited = false;
        maxTxAmount = 10000000 * 10 ** 18;
        maxTokensForWallet = 10000 * 10 ** 18;
    }


    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }


    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    
    /**
     * @dev Returns the decimals of the token
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    
    /**
     * @dev Returns the total supply of the contract
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    
    /**
     * @dev Returns the balance of a specific account
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    
    /**
     * @dev Transfer amount of token from msg.sender to the recipient
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    
    /**
     * @dev Change wallet addres by a specific position
     * @param pos of wallet
     * @param newAddress of the wallet
     */
    function changeWalletAddress(uint256 pos, address newAddress) public withGrant returns(bool){
        require(pos > 0 && pos < 4, "Position is not valid");
        require(newAddress != address(0x0), "Address is not valid");
        
        if(pos == 1){
            marketWallet = newAddress;
        }else if(pos == 2){
            devWallet = newAddress;
        }else if(pos == 3){
            LPWallet = newAddress;
        }
        return true;
    }
    
    
    /** 
     * @dev Changes fee of a specific wallet
     * @param pos of wallet
     * @param updatedFee for walle
     */
    function changeFeeOfWallet(uint256 pos, uint256 updatedFee) public withGrant returns(bool){
        require(pos > 0 && pos < 4, "Position is not valid");
        require(updatedFee >= 0 && updatedFee <= 10, "The fee is not valid");
        
        if(pos == 1){
            marketFee = updatedFee;
        }else if(pos == 2){
            devFee = updatedFee;
        }else if(pos == 3){
            LPFee = updatedFee;
        }
        return true;
    }


    /**
     * @dev Excludes a specific address from fees
     * @param excludeAddr address to be excluded
    */
    function excludeAddrFromFee(address excludeAddr) public withGrant returns(bool){
        require(excludeAddr != address(this), "excludeAddr cannot be this contract");
        require(excludeAddr != address(0x0), "excludeAddr is not valid");

        _isExcludedFromFee[excludeAddr] = true;
        return true;
    }


    /**
     * @dev Includes a specific address with fees
     * @param includeAddr address to be included
    */
    function includeAddrFromFee(address includeAddr) public withGrant returns(bool){
        require(includeAddr != address(this), "excludeAddr cannot be this contract");
        require(includeAddr != address(0x0), "excludeAddr is not valid");

        _isExcludedFromFee[includeAddr] = true;
        return true;
    }
    
    
    /**
     * @dev Returns maximum transation amount
     */
    function getMaxTxAmount() public view returns(uint256) {
        return maxTxAmount;
    }
    
    
    /**
     * @dev Sets a new maximum transaction amount
     * @param _maxAmount of tokens
     */
    function setMaxTxAmount(uint256 _maxAmount) public withGrant returns(bool){
        require(_maxAmount > 0, "Max tx amount cannot be zero");

        maxTxAmount = _maxAmount;
        return true;
    }
    
    
    /**
     * @dev Returns maximum number of tokens for wallet
     */
    function getMaxTokensForWallet() public view returns(uint256){
        return maxTokensForWallet;
    }
    
    
    /**
     * @dev Sets a new maximum number of tokens for wallet
     * @param newMaxTokenForWallet number of token
     */
    function setMaxTokensForWallet(uint256 newMaxTokenForWallet) public withGrant returns(bool){
        require(newMaxTokenForWallet >= 0, "newMaxTokenForWallet cannot be less than 0");
        
        maxTokensForWallet = newMaxTokenForWallet;
        return true;
    }

    
    /**
     * @dev Sets takeFee flag with the given status    
     * @param status boolean flag
     */
    function setTakeFee(bool status) public withGrant returns(bool){
        require(takeFee != status, "status is already set");
        takeFee = status;
        return true;
    }


    /**
     * @dev Sets limited flag with the given status    
     * @param status boolean flag
     */
    function setLimited(bool status) public withGrant returns(bool){
        require(limited != status, "status is already set");
        limited = status;
        return true;
    }

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        if(limited){
            require(amount <= maxTxAmount, "Amount exceeds the limit");
            require(_balances[recipient] + amount <= maxTokensForWallet, "Amount exceeds the limit of wallet");
        }

        if(_isExcludedFromFee[sender] || !takeFee){
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }else{
            uint256 calculatedMarketFee = calculateMarketFee(amount);
            uint256 calculatedDevFee = calculateDevFee(amount);
            uint256 calculatedLPFee = calculateLPFee(amount);
            uint256 amountWithFee = amount.sub(calculatedMarketFee).sub(calculatedDevFee).sub(calculatedLPFee);

            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amountWithFee);
            _balances[marketWallet] = _balances[marketWallet].add(calculatedMarketFee);
            _balances[devWallet] = _balances[devWallet].add(calculatedDevFee);
            _balances[LPWallet] = _balances[LPWallet].add(calculatedLPFee);

            emit Transfer(sender, recipient, amountWithFee); 
        }
    }

    
    /**
     * @dev Calculates and returns fee of Marketing
     * @param amount of transaction
     */
    function calculateMarketFee(uint256 amount) internal view returns(uint256){
        uint256 marketFeeValue = amount.div(100).mul(marketFee);
        return marketFeeValue;
    }


    /**
     * @dev Calculates and returns fee of Development
     * @param amount of transaction
     */
    function calculateDevFee(uint256 amount) internal view returns(uint256){
        uint256 developmentFeeValue = amount.div(100).mul(devFee);
        return developmentFeeValue;
    }


    /**
     * @dev Calculates and returns fee of LP
     * @param amount of transaction
     */
    function calculateLPFee(uint256 amount) internal view returns(uint256){
        uint256 LPFeeValue = amount.div(100).mul(LPFee);
        return LPFeeValue;
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        //_beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);

        //_afterTokenTransfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        //_beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        //_afterTokenTransfer(account, address(0), amount);
    }

    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}