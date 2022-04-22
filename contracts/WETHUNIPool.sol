//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./LPToken.sol";

contract WETHUNIPool is Ownable {
    // address public wethAddress = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    // address public uniswapAddress = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    // 0.3%
    uint256 public feePercent = 3;
    uint256 public feeDecimals = 1;
    string public token1Name;
    string public token2Name;

    uint256 public reserveToken1 = 0;
    uint256 public reserveToken2 = 0;
    event LiquidityAdded(
        address indexed _from,
        uint256 _amount1,
        uint256 _amount2
    );
    event LiquidityWithdrawn(
        address indexed _from,
        uint256 _amount1,
        uint256 _amount2,
        uint256 _lpTokens
    );

    IERC20 public token1;
    IERC20 public token2;
    LPToken public lpToken;

    enum Token {
        TOKEN1,
        TOKEN2
    }

    constructor(
        address _token1,
        address _token2,
        string memory _name1,
        string memory _name2
    ) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
        token1Name = _name1;
        token2Name = _name2;

        lpToken = new LPToken("LPToken", "LP");
        // 0.3%
        feePercent = 3;
        feeDecimals = 1;
    }

    // TODO: require minimum swap amount limit

    function swap(uint256 _amount, Token _sendingToken)
        external
        reserveNotZero
        returns (bool)
    {
        // 0. Check if sending token is approved for transfer
        if (_sendingToken == Token.TOKEN1) {
            require(
                token1.allowance(msg.sender, address(this)) >= _amount,
                "Not enough allowance"
            );
        } else {
            require(
                token2.allowance(msg.sender, address(this)) >= _amount,
                "Not enough allowance"
            );
        }
        // 1. Send resulting tokens to user
        uint256 _resultingTokens = resultingTokens(_amount, _sendingToken);
        if (_sendingToken == Token.TOKEN1) {
            token2.transfer(msg.sender, _resultingTokens);
        } else if (_sendingToken == Token.TOKEN2) {
            token1.transfer(msg.sender, _resultingTokens);
        } else {
            assert(true);
        }
        // 2. Update reserve values
        if (_sendingToken == Token.TOKEN1) {
            reserveToken1 += _amount;
            reserveToken2 -= _resultingTokens;
        } else if (_sendingToken == Token.TOKEN2) {
            reserveToken2 += _amount;
            reserveToken1 -= _resultingTokens;
        }
        // 3. TODO - external function

        // 4. transfer tokens to contract
        (_sendingToken == Token.TOKEN1 ? token1 : token2).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        return true;
    }

    // Caculate result to transfer for swapping
    function resultingTokens(uint256 _amount, Token _sendingToken)
        public
        view
        reserveNotZero
        returns (uint256)
    {
        uint256 _result = 0;
        uint256 _reserveToken1 = reserveToken1;
        uint256 _reserveToken2 = reserveToken2;
        uint256 _kconst = reserveToken1 * reserveToken2;
        if (_sendingToken == Token.TOKEN1) {
            uint256 _endingToken2Reserve = (_kconst /
                (_amount - _calculateFee(_amount) + _reserveToken1));

            require(
                _endingToken2Reserve <= reserveToken2,
                "Not enough reserve token 2"
            );
            _result = reserveToken2 - _endingToken2Reserve;
        } else if (_sendingToken == Token.TOKEN2) {
            uint256 _endingToken1Reserve = (_kconst /
                (_amount - _calculateFee(_amount) + _reserveToken2));
            require(
                _endingToken1Reserve <= reserveToken1,
                "Not enough reserve token 1"
            );
            _result = reserveToken1 - _endingToken1Reserve;
        }
        return _result;
    }

    function _calculateFee(uint256 _tokenAmount)
        private
        view
        returns (uint256)
    {
        uint256 fee = ((_tokenAmount * feePercent) / 100) / (10**feeDecimals);
        return fee;
    }

    // add Liquidity
    function addLiquidity(uint256 _amount1, uint256 _amount2)
        external
        returns (bool)
    {
        require(_amount1 > 0 && _amount2 > 0, "Amounts must be greater than 0");
        require(
            token1.allowance(msg.sender, address(this)) >= _amount1,
            "Not enough allowance"
        );
        require(
            token2.allowance(msg.sender, address(this)) >= _amount2,
            "Not enough allowance"
        );
        bool success = token1.transferFrom(msg.sender, address(this), _amount1);
        bool success2 = token2.transferFrom(
            msg.sender,
            address(this),
            _amount2
        );
        require(success && success2, "Tokens transfer failed");
        uint256 _lpTokensToMint = _calculateLpTokens(_amount1, _amount2);
        lpToken._mint(msg.sender, _lpTokensToMint);
        reserveToken1 += _amount1;
        reserveToken2 += _amount2;
        emit LiquidityAdded(msg.sender, _amount1, _amount2);
        return true;
    }

    // withdraw liquidity
    function withdrawLiquidity()
        external
        isLiquidityProvider(msg.sender)
        returns (bool)
    {
        uint256 lpTokensBalance = lpToken.balanceOf(msg.sender);
        // 0. Calc percentage to give from lptoken/totalsupply*100
        uint256 _percentageToGive = (lpTokensBalance / lpToken.totalSupply()) *
            100;
        // 1. Calc amount of token1 to give
        uint256 _amount1ToGive = (reserveToken1 * _percentageToGive) / 100;
        // 2. Calc amount of token2 to give
        uint256 _amount2ToGive = (reserveToken2 * _percentageToGive) / 100;
        // 3. burn lp token
        lpToken._burn(msg.sender, lpTokensBalance);
        // 4. transfer tokens
        token1.transfer(msg.sender, _amount1ToGive);
        token2.transfer(msg.sender, _amount2ToGive);
        // 5. update reserve values
        reserveToken1 -= _amount1ToGive;
        reserveToken2 -= _amount2ToGive;
        // 6. Emit event
        emit LiquidityWithdrawn(
            msg.sender,
            _amount1ToGive,
            _amount2ToGive,
            lpTokensBalance
        );
        return true;
    }

    // check contract token1 balance
    function token1Balance() public view returns (uint256) {
        return token1.balanceOf(address(this));
    }

    // check contract token2 balance
    function token2Balance() public view returns (uint256) {
        return token2.balanceOf(address(this));
    }

    modifier isLiquidityProvider(address _account) {
        require(lpToken.balanceOf(_account) > 0, "Not a liquidity provider");
        _;
    }

    function productConstant() public view returns (uint256) {
        return reserveToken1 * reserveToken2;
    }

    function _calculateLpTokens(uint256 _amount1, uint256 _amount2)
        private
        pure
        returns (uint256)
    {
        return _floorSqrt(_amount1 * _amount2);
    }

    /**
     * @dev Compute the largest integer smaller than or equal to the square root of `n`
     */
    function _floorSqrt(uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n > 0) {
                uint256 x = n / 2 + 1;
                uint256 y = (x + n / x) / 2;
                while (x > y) {
                    x = y;
                    y = (x + n / x) / 2;
                }
                return x;
            }
            return 0;
        }
    }

    function destroyContract() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }

    function lpTokenBalanceOf(address _account) public view returns (uint256) {
        return lpToken.balanceOf(_account);
    }

    function lpTokenSupply() public view returns (uint256) {
        return lpToken.totalSupply();
    }

    modifier reserveNotZero() {
        require(
            reserveToken1 > 0 && reserveToken2 > 0,
            "Reserve tokens must be greater than 0"
        );
        _;
    }
}

//  function callOther() public  {
//         (bool success, bytes memory result) = address(other).delegatecall(abi.encodeWithSignature("callme()"));
//         console.log("success: " , success);
//         console.log(abi.decode(result, (address)));
//     }
