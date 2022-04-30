//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pool.sol";

contract PoolFactory {
    mapping(address => mapping(address => address)) public tokensToPool;

    event PoolCreated(
        address indexed _pool,
        address indexed _token1,
        address indexed _token2
    );

    // Create a pool
    function createPool(
        address _token1,
        address _token2,
        string memory _name1,
        string memory _name2
    ) public returns (address) {
        require(getPool(_token1, _token2) == address(0), "Pool already exists");
        require(_token1 != _token2, "Tokens cannot be the same");
        require(
            _token1 != address(0) && _token2 != address(0),
            "Token 1 cannot be 0x0"
        );
        Pool newPool = new Pool(_token1, _token2, _name1, _name2);
        address newPoolAddress = address(newPool);

        tokensToPool[_token1][_token2] = newPoolAddress;
        tokensToPool[_token2][_token1] = newPoolAddress;

        emit PoolCreated(newPoolAddress, _token1, _token2);
        return newPoolAddress;
    }

    // get pool address for token addresses
    function getPool(address _token1, address _token2)
        public
        view
        returns (address)
    {
        require(_token1 != _token2, "Token1 and Token2 cannot be the same");
        require(
            _token1 != address(0) && _token2 != address(0),
            "Token1 and Token2 cannot be zero address"
        );
        return tokensToPool[_token1][_token2];
    }
}
