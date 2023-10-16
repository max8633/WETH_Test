// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract WETH is ERC20, ERC20Burnable {

    event Deposit(address indexed addr, uintt256 amount);
    event Withdraw(address indexed addr, uint256 amount);

    constructor() ERC20("Wrapped ether", "WETH") {}

    function deposit() external payable{
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint _amount) external payable{
        require(balanceOf(msg.sender) >=_amount,"Failed" );
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
    }
}

