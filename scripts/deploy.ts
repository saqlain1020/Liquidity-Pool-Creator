import hre from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const ContractFactory = await hre.ethers.getContractFactory("Pool");
  const constructorArguments = [
    "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6",
    "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
    "WETH",
    "UNI",
  ];
  const contract = await ContractFactory.deploy(
    constructorArguments[0],
    constructorArguments[1],
    constructorArguments[2],
    constructorArguments[3]
  );

  await contract.deployed();

  console.log("Contract deployed to:", contract.address);

  await contract.deployTransaction.wait();

  hre.network.name === "hardhat"
    ? console.log("Skipping verify")
    : await verifyContract(contract.address, constructorArguments);
}

function verifyContract(contractAddress: string, constructorArguments: string[], intervalSec: number = 10) {
  return new Promise<void>(async (res, rej) => {
    (async function verify() {
      try {
        console.log("Verifying Contract");
        await hre.run("verify:verify", {
          address: contractAddress,
          constructorArguments,
        });
        console.log("Verify Success");
        res();
      } catch (error) {
        console.log("Verify Error");
        let timer = intervalSec;
        let int = setInterval(() => {
          console.log("Trying again in " + timer);
          timer--;
          if (timer === 0) {
            clearInterval(int);
            verify();
          }
        }, 1000);
      }
    })();
    setTimeout(rej, 1000 * 60 * 5); // 5 minutes timeout
  });
}

// async function getGasEstimate(contractInstance, methodName, ...args) {
//   let gasPriceBigNumberWei = await hre.ethers.provider.getGasPrice();
//   let gasPriceGwei = hre.ethers.utils.formatUnits(gasPriceBigNumberWei, 'gwei');

//   let gasUnitsEstimate = await contractInstance.estimateGas[methodName](...args);
//   let estimate = Number(gasPriceGwei) * Number(gasUnitsEstimate)
//   // gwei to eth
//   estimate = estimate / 1000000000;
//   console.log("Estimated gas eth:", estimate);
// }

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// main()
