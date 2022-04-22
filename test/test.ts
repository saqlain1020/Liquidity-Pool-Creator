import { expect } from "chai";
import { BigNumberish, ContractReceipt } from "ethers";
import { ethers } from "hardhat";
import JsonData from "../artifacts/contracts/WETHUNIPool.sol/WETHUNIPool.json";
import { LPToken, WETHUNIPool } from "../typechain-types";

describe("ETHUNIPool", function () {
  it("Should pass the test", async function () {
    const [owner] = await ethers.getSigners();
    const ContractFactoryToken1 = await ethers.getContractFactory("LPToken");
    const ContractFactoryToken2 = await ethers.getContractFactory("LPToken");
    const contractToken1 = await ContractFactoryToken1.deploy("Token1", "T1");
    const contractToken2 = await ContractFactoryToken2.deploy("Token2", "T2");
    await contractToken1.deployed();
    await contractToken2.deployed();
    const ContractFactoryPool = await ethers.getContractFactory("WETHUNIPool");
    const contractPool = await ContractFactoryPool.deploy(contractToken1.address, contractToken2.address, "T1", "T2");
    contractPool.deployed();

    contractToken1._mint(owner.address, toWei("1000000"));
    contractToken2._mint(owner.address, toWei("1000000"));

    await getBalances(contractToken1, contractToken2, owner.address);

    await contractToken1.approve(contractPool.address, toWei("100"));
    await contractToken2.approve(contractPool.address, toWei("100"));

    await getAllowance(owner.address, contractPool.address, contractToken1);
    await getAllowance(owner.address, contractPool.address, contractToken2);

    await addLiquidity(50, 100, contractPool);
    await getBalances(contractToken1, contractToken2, owner.address);

    let resultingOfSwap = await contractPool.resultingTokens(toWei("10"), "0");
    expect(Number(toEth(resultingOfSwap))).to.greaterThanOrEqual(16);
    console.log("After swap should get", toEth(resultingOfSwap));

    await contractPool.swap(toWei("10"), "0");
    await debugContractBalances(contractPool, contractToken1, contractToken2);

    await getBalances(contractToken1, contractToken2, owner.address);
    
    await getLpTokenBalance(contractPool, owner.address);
    await getLpTokenSupply(contractPool);
    
    let receipt = await (await contractPool.withdrawLiquidity()).wait();
    printLastEvent(receipt);
    
    console.log("After withdraw");
    console.log("Contract Tokens")
    console.log(toEth(await contractPool.reserveToken1()))
    console.log(toEth(await contractPool.reserveToken2()))
    await getBalances(contractToken1, contractToken2, owner.address);
  });
});

async function printLastEvent(receipt : ContractReceipt) {
  let iface = new ethers.utils.Interface(JsonData.abi);
  let args = iface.parseLog(receipt.logs[receipt.logs.length - 1]).args;
  console.log(args);
  return args;
}

async function debugContractBalances(contract: WETHUNIPool, token1: LPToken, token2: LPToken) {
  let res1 = toEth(await contract.reserveToken1());
  let res2 = toEth(await contract.reserveToken2());
  let actual1 = toEth(await token1.balanceOf(contract.address));
  let actual2 = toEth(await token2.balanceOf(contract.address));
  console.log("Res 1:", res1);
  console.log("Actual 1:", actual1);
  console.log("Res 2:", res2);
  console.log("Actual 2:", actual2);
}

async function getLpTokenSupply(contract: WETHUNIPool) {
  console.log("LP Tokens Supply:", toEth(await contract.lpTokenSupply()));
}
async function getLpTokenBalance(contract: WETHUNIPool, owner: string) {
  console.log("LP Tokens:", toEth(await contract.lpTokenBalanceOf(owner)));
}

async function getBalances(contract: LPToken, contract2: LPToken, owner: string) {
  console.log("Balances");
  console.log(await contract.symbol(), ethers.utils.formatEther(await contract.balanceOf(owner)));
  console.log(await contract2.symbol(), ethers.utils.formatEther(await contract2.balanceOf(owner)));
}

async function getAllowance(owner: string, sender: string, contract: LPToken) {
  let sym = await contract.symbol();
  let allowance = await contract.allowance(owner, sender);
  console.log(sym, "Allowance", toEth(allowance));
}

async function addLiquidity(amount1: number, amount2: number, contract: WETHUNIPool) {
  let receipt = await (await contract.addLiquidity(toWei(amount1), toWei(amount2))).wait();

  const iface = new ethers.utils.Interface(JsonData.abi);
  const [_from, _amount1, _amount2] = iface.parseLog(receipt.logs[receipt.logs.length - 1]).args;

  console.log("liquidity Added", _from, toEth(_amount1), toEth(_amount2));
}

function toEth(wei: BigNumberish) {
  return ethers.utils.formatEther(wei);
}

function toWei(eth: string | number) {
  return ethers.utils.parseEther(eth.toString());
}

// const contract = await ContractFactory.deploy();
// await contract.deployed();
// const [owner, add1, add2] = await ethers.getSigners();

// let gasPriceBigNumberWei = await ethers.provider.getGasPrice();
//   let gasPriceGwei = hre.ethers.utils.formatUnits(gasPriceBigNumberWei, 'gwei');

//   let gasUnitsEstimate = await contract.estimateGas["openCommitee"]();
//   let estimate = Number(gasPriceGwei) * Number(gasUnitsEstimate)
//   // gwei to eth
//   estimate = estimate / 1000000000;
//   console.log("Estimated gas eth:", estimate);

