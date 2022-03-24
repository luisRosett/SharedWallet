// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Allowance is Ownable{

//Indexed to find for a certain address later. This generates the event that will be emitted later 
    event AllowanceChanged (address indexed _forWho, address indexed _fromWhom, uint _oldAmount, uint _newAmount);

    mapping(address => uint) public allowance;

    function addAllowance(address _who, uint _amount) public onlyOwner{
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = _amount;
    }

    modifier ownerOrAllowed(uint _amount) {
        require(msg.sender == owner() || allowance[msg.sender] >= _amount, "Your are not allowed");
        _;
    }

    function reduceAllowance(address _who, uint _amount) internal {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who] - _amount);
        allowance[_who] -= _amount;
    }
}

contract SimpleWallet is Allowance{

    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount){
        require(_amount <= address(this).balance, "There are not enought funds stored in the Smart Contract");
        if(msg.sender != owner()){
            reduceAllowance(msg.sender, _amount);
        }
        _to.transfer(_amount);

    }

    fallback () external payable {
        
    }
}