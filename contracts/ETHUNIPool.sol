//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract ETHUNIPool is Ownable {
    address public uniswapAddress = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address public wethAddress = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    mapping(address => LiquidityProvider) public liquidityProviders;
    uint256 public lastRewardTime;
    uint256 public rewardCycleInterval = 5 minutes;
    uint256 private productConstant = 0;
    // 0.3%
    uint256 feePercent = 3;
    uint256 feeDecimals = 1;

    uint256 private wethFeesCollected = 0;
    uint256 private uniswapFeesCollected = 0;
    uint256 private totalWethLiquidity = 0;
    uint256 private totalUniswapLiquidity = 0;
    address[] public liquidityProvidersAddresses;

    struct LiquidityProvider {
        uint256 uniswapLiquidity;
        uint256 wethLiquidity;
        uint256 wethRewardAvailable;
        uint256 uniRewardAvailable;
        uint32 index;
        bool isProvider;
    }

    IERC20 public uniswap;
    IERC20 public weth;

    constructor() {
        // TODO add fees, token1, token2 to constructor arguments
        uniswap = IERC20(uniswapAddress);
        weth = IERC20(wethAddress);
        lastRewardTime = block.timestamp;
    }

    // TODO: require minimum swap amount limit
    // TODO: get estimated swap amount

    // Swap Eth for Uniswap with fee distribute as well
    // Fees is paid first from the token being swapped out
    // Swap Uniswap for Eth with fee distribute as well
    /**
        Swapping Steps:
        1. Check if the user has enough balance to swap
        2. Calulate Fee method
        3. Put tokens in contract
        4. calculate tokens to transfer user with given amount - fees deducted using formulas (create method)
        5. transfer tokens to user
        6. call distributeFees()
     */

    function _calculateFee(uint256 _tokenAmount)
        private
        view
        returns (uint256)
    {
        uint256 fee = ((_tokenAmount * feePercent) / 100) / (10**feeDecimals);
        return fee;
    }

    // calculate percentage liquidity share for address
    function _calculateLiquidityShare(address _address)
        private
        view
        returns (uint256)
    {
        uint256 totalLiquidityOfAddress = liquidityProviders[_address]
            .uniswapLiquidity + liquidityProviders[_address].wethLiquidity;
        uint256 share = (totalLiquidityOfAddress /
            (totalWethLiquidity + totalUniswapLiquidity)) * 100;
        return share;
    }

    // withdraw rewards
    function withdrawRewards() external isLiquidityProvider(msg.sender) {
        uniswap.transfer(
            msg.sender,
            liquidityProviders[msg.sender].uniRewardAvailable
        );
        liquidityProviders[msg.sender].uniRewardAvailable = 0;
        weth.transfer(
            msg.sender,
            liquidityProviders[msg.sender].wethRewardAvailable
        );
        liquidityProviders[msg.sender].wethRewardAvailable = 0;
    }

    // withdraw liquidity
    function withdrawLiquidity() external isLiquidityProvider(msg.sender) {
        if (liquidityProviders[msg.sender].uniswapLiquidity > 0)
            uniswap.transfer(
                msg.sender,
                liquidityProviders[msg.sender].uniswapLiquidity
            );
        if (liquidityProviders[msg.sender].wethLiquidity > 0)
            weth.transfer(
                msg.sender,
                liquidityProviders[msg.sender].wethLiquidity
            );
        if (liquidityProviders[msg.sender].uniRewardAvailable > 0)
            uniswap.transfer(
                msg.sender,
                liquidityProviders[msg.sender].uniRewardAvailable
            );
        if (liquidityProviders[msg.sender].wethRewardAvailable > 0)
            weth.transfer(
                msg.sender,
                liquidityProviders[msg.sender].wethRewardAvailable
            );
        liquidityProviders[msg.sender].wethLiquidity = 0;
        liquidityProviders[msg.sender].uniswapLiquidity = 0;
        liquidityProviders[msg.sender].uniRewardAvailable = 0;
        liquidityProviders[msg.sender].wethRewardAvailable = 0;
        _removeLiquidityProvider(msg.sender);
    }

    //Distribute providers payout
    function _distributeFeesRewards() private {
        if (lastRewardTime + rewardCycleInterval >= block.timestamp) {
            // TODO
            for (uint256 i = 0; i < liquidityProvidersAddresses.length; i++) {
                uint256 share = _calculateLiquidityShare(
                    liquidityProvidersAddresses[i]
                );
                uint256 wethReward = (share / 100) * wethFeesCollected;
                uint256 uniReward = (share / 100) * uniswapFeesCollected;
                liquidityProviders[liquidityProvidersAddresses[i]]
                    .wethRewardAvailable += wethReward;
                liquidityProviders[liquidityProvidersAddresses[i]]
                    .uniRewardAvailable += uniReward;
            }

            wethFeesCollected = 0;
            uniswapFeesCollected = 0;
            lastRewardTime = block.timestamp;
        }
    }

    // check contract uniswap balance
    function contractUniswapBalance() public view returns (uint256) {
        return uniswap.balanceOf(address(this));
    }

    // check contract eth balance
    function contractEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // add liquidity eth
    function addWethLiquidity(uint256 _amount) external {
        (bool success, ) = address(weth).delegatecall(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(this),
                _amount
            )
        );
        require(success);
        liquidityProviders[msg.sender].wethLiquidity += _amount;
        totalWethLiquidity += _amount;
        _addLiquidityProvider(msg.sender);
        _updateProductConstant();
    }

    // add liquidity uniswap
    function addUniswapLiquidity(uint256 _amount) external {
        (bool success, ) = address(uniswap).delegatecall(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(this),
                _amount
            )
        );
        require(success);
        liquidityProviders[msg.sender].uniswapLiquidity += _amount;
        totalUniswapLiquidity += _amount;
        _addLiquidityProvider(msg.sender);
        _updateProductConstant();
    }

    // update product constant
    function _updateProductConstant() private {
        uint256 newConstant = totalWethLiquidity * totalUniswapLiquidity;
        productConstant = newConstant;
    }

    // check if product constant is greater than zero
    modifier productConstantExists() {
        require(productConstant > 0, "Prduct Constant is zero");
        _;
    }

    modifier isLiquidityProvider(address _account) {
        require(
            liquidityProviders[_account].isProvider,
            "Not a liquidity provider"
        );
        _;
    }

    function _addLiquidityProvider(address _add) private {
        if (!liquidityProviders[_add].isProvider) {
            liquidityProviders[_add].isProvider = true;
            liquidityProvidersAddresses.push(_add);
            liquidityProviders[_add].index = uint32(
                liquidityProvidersAddresses.length - 1
            );
        }
    }

    // remove liquidity provider
    function _removeLiquidityProvider(address _provider)
        private
        isLiquidityProvider(_provider)
    {
        require(
            liquidityProviders[_provider].uniswapLiquidity == 0 &&
                liquidityProviders[_provider].wethLiquidity == 0,
            "Liquidity provider has liquidity"
        );
        require(
            liquidityProviders[_provider].wethRewardAvailable == 0 &&
                liquidityProviders[_provider].uniRewardAvailable == 0,
            "Liquidity provider has rewards which can be claimed"
        );

        liquidityProvidersAddresses[
            liquidityProviders[_provider].index
        ] = liquidityProvidersAddresses[liquidityProvidersAddresses.length - 1];
        liquidityProvidersAddresses.pop();

        delete liquidityProviders[_provider];
    }
}

//  function callOther() public  {
//         (bool success, bytes memory result) = address(other).delegatecall(abi.encodeWithSignature("callme()"));
//         console.log("success: " , success);
//         console.log(abi.decode(result, (address)));
//     }
