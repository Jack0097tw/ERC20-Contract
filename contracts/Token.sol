// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//合約導入ERC20、Ownable套件
contract MyToken is ERC20, Ownable {
    uint256 public taxRate = 2; // 2% 交易手續費
    address public taxCollector; // 稅接收者
    mapping(address => bool) private _isExcludedFromFee;

    //合約部屬參數設定
    constructor(address _taxCollector) ERC20("MyToken", "MTK") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10**decimals()); // 初始供應量 100 萬
        taxCollector = _taxCollector;
        _isExcludedFromFee[msg.sender] = true; // 合約擁有者免手續費
    }

    //編寫新的ERC20的transfer function邏輯，取代ERC20.sol中的trasnfer function
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return _transferWithTax(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(allowance(sender, msg.sender) >= amount, "ERC20: transfer amount exceeds allowance"); //驗證本次交易數量amount是否低於sender授權額度
        _approve(sender, msg.sender, allowance(sender, msg.sender) - amount); //更新msg.sender被approve的數量
        return _transferWithTax(sender, recipient, amount);
    }

    function _transferWithTax(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 taxAmount = _isExcludedFromFee[sender] ? 0 : (amount * taxRate) / 100;
        uint256 transferAmount = amount - taxAmount;

        if (taxAmount > 0) { 
            super._transfer(sender, taxCollector, taxAmount);//sender先將交易稅先轉給稅接收者
        }
        super._transfer(sender, recipient, transferAmount);//sender再將代幣轉給接收者
        return true;
    }

    function excludeFromFee(address account, bool excluded) external onlyOwner {
        _isExcludedFromFee[account] = excluded;
    }

    function setTaxRate(uint256 _taxRate) external onlyOwner {
        require(_taxRate <= 10, "Tax rate cannot exceed 10%");
        taxRate = _taxRate;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    //批量轉帳
    //不建議，可能被DoS 攻擊!!
    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "Mismatched array lengths");
        for (uint256 i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
    }    
}