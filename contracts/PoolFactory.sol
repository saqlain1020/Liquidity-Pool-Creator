//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Pool.sol";

contract PoolFactory {
    Pool[] public pools;
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
        Pool newPool = new Pool(_token1, _token2, _name1, _name2);
        pools.push(newPool);
        address newPoolAddress = address(newPool);
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
            "Token1 and Token2 cannot be the same"
        );
        if (pools.length == 0) return address(0);
        for (uint256 i = 0; i < pools.length; i++) {
            if (
                pools[i].token1Address() == _token1 &&
                pools[i].token2Address() == _token2
            ) {
                return address(pools[i]);
            } else if (
                pools[i].token1Address() == _token2 &&
                pools[i].token2Address() == _token1
            ) {
                return address(pools[i]);
            }
        }
        return address(0);
    }
}
