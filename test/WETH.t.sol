// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {WETHContract} from "../src/WETH.sol";

contract WETHTest is Test{

    WETHContract public weth;
    address user1;
    address user2;

    event Deposit(address indexed addr, unit256 amount);
    event Withdraw(address indexed addr, unit256 amount);

    function setUp() public {
        user1 = makeAdde("user1");
        user2 = makeAdde("user2");
        weth = new WETH("Wrapped ether", "WETH");
    }
    
    //測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    function test_DepositBalance() public {
        vm.startPrank(user1);
        deal(user1, 1 ether);
        (bool result,) = address(weth).call{value: 1 ether}("");
        require(result);
        assertEq(weth.balanceOf(user1), 1e18);

        vm.stopPrank();
    }

    //測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function test_DepositContractBalance() public {
        vm.startPrank(user1);
        deal(user1, 1 ether);
        (bool result,) = address(weth).call{value: 1 ether}("");
        require(result);
        assertEq(address(weth).balance, 1 ether);

        vm.stopPrank();
    }

    //測項 3: deposit 應該要 emit Deposit event
    function test_DepositEvent() public {
        vm.startPrank(user1);
        deal(user1, 1 ether);

        vm.expectEmit(true, false, false, false);
        emit Deposit(user1, address(weth), 1 ether); 

        (bool result,) = address(weth).call{value: 1 ether}("");
        require(result);
        assertEq(address(weth).balance, 1 ether);      
    }

    //測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
    function test_WithdrawBruned() public {
        vm.startPrank(user1);
        deal(user1, 1 ether);
        (bool result,) = address(weth).call{value: 1 ether}("");
        require(result);
        assertEq(address(weth).balance, 1 ether); 

        weth.withdraw(1 ether);
        assertEq(address(weth).balance, 0);
        vm.stopPrank();
    }

    //測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
    function test_WithdrawUserBalance() public {
        vm.startPrank(user1);
        deal(user1, 1 ether);
        (bool result,) = address(weth).call{value: 1 ether}("");
        require(result);
        assertEq(address(weth).balance, 1 ether); 

        weth.withdraw(1 ether);
        assertEq(weth.balanceOf(user1), 1 ether);
        
        vm.stopPrank();
    }

    //測項 6: withdraw 應該要 emit Withdraw event
    function test_WithdrawEvent() public {
        vm.startPrank(user1);
        deal(user1, 1 ether);

        vm.expectEmit(true, false, false, false);
        emit Withdraw(address(weth), user1, 1 ether); 

        (bool result,) = address(weth).call{value: 1 ether}("");
        require(result);
        assertEq(weth.balanceOf(user1), 1 ether);   
    }

    //測項 7: transfer 應該要將 erc20 token 轉給別人
    function test_TransferToken() public {
        vm.startPrank(user1);
        deal(user1, 1 ether);
        (bool result,) = address(weth).call{value: 1 ether}("");
        require(result);
        assertEq(address(weth).balance, 1 ether); 

        address(weth).transfer(user2, 1e18);
        assertEq(weth.balanceOf(user1), 0);
        assertEq(weth.balanceOf(user2), 1e18);

        vm.stopPrank();
    }

    //測項 8: approve 應該要給他人 allowance
    function test_ApproveWithAllowance() public {
        vm.startPrank(user1);
        deal(user1, 1 ether);
        (bool result,) = address(weth).call{value: 1 ether}("");
        require(result);
        assertEq(address(weth).balance, 1 ether); 

        weth.approve(user2, 1e18);
        assertEq(weth.allowance(user1, user2), 1e18);
        vm.stopPrank();
    }

    //測項 9: transferFrom 應該要可以使用他人的 allowance
    function test_TransferFrom() public {
        vm.startPrank(user1);
        deal(user1, 1 ether);
        (bool result,) = address(weth).call{value: 1 ether}("");
        require(result);
        assertEq(address(weth).balance, 1 ether); 

        weth.approve(user2, 1e18);
        weth.transferFrom(user1, user2, 1e18);
        assertEq(weth.balanceOf(user1), 0);
        assertEq(weth.balanceOf(user2), 1);

        vm.stopPrank();
    }

    //測項 10: transferFrom 後應該要減除用完的 allowance
    function test_TransferFromAllowance() public {
        vm.startPrank(user1);
        deal(user1, 1 ether);
        (bool result,) = address(weth).call{value: 1 ether}("");
        require(result);
        assertEq(address(weth).balance, 1 ether); 

        weth.approve(user2, 1e18);
        weth.transferFrom(user1, user2, 1e18);
        assertEq(weth.allowance(user1, user2), 0);

        vm.stopPrank();               
    }
}