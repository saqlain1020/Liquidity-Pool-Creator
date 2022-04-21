//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LPToken is Ownable, IERC20 {
    string public name = "LPToken";
    string public symbol = "LP";
    uint8 public decimals = 18;
    uint256 public totalSupply = 0 * 10**18;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function _mint(address _to, uint256 _amount) external onlyOwner {
        totalSupply += _amount;
        balances[_to] += _amount;
    }

    function _burn(address _from, uint256 _amount) external onlyOwner {
        totalSupply -= _amount;
        balances[_from] -= _amount;
    }

    function balanceOf(address _account) external view returns (uint256) {
        return balances[_account];
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256)
    {
        return allowances[_owner][_spender];
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 value
    ) private {
        allowances[_owner][_spender] = value;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        require(_value <= balances[msg.sender]);
        _approve(msg.sender, _spender, _value);
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) private {
        balances[_from] -= _value;
        balances[_to] += _value;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool) {
        require(balances[_from] >= _value);
        require(allowances[_from][_to] >= _value);
        _transfer(_from, _to, _value);
        allowances[_from][_to] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(balances[msg.sender] >= _amount);
        _transfer(msg.sender, _to, _amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
}
