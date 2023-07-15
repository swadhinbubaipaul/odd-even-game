// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const oddEvenGame = await hre.ethers.deployContract("OddEvenGame", [
    "100000000000000000",
    "3642",
    "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625",
    "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c",
  ]);

  await oddEvenGame.waitForDeployment();

  console.log(`OddEvenGame contract deployed to ${oddEvenGame.target}`);
  //0x3fCd113fc4Ae3819F28B036243aCe79a05f1f467
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
