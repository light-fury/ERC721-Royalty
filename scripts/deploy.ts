import { ethers } from "hardhat";

async function main() {
  const OpenseaNFT721 = await ethers.getContractFactory("OpenseaNFT721");
  const openseaNFT721 = await OpenseaNFT721.deploy(300, "", "");

  await openseaNFT721.deployed();

  console.log(`OpenseaNFT721 deployed to ${openseaNFT721.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
