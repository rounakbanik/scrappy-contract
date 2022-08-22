const { utils } = require("ethers");

const main = async () => {

  const baseTokenURI = "<--JSON IPFS Address Here-->"
  const [owner] = await hre.ethers.getSigners();
  const nftContractFactory = await hre.ethers.getContractFactory('ScrappySquirrels');
  const nftContract = await nftContractFactory.deploy(baseTokenURI);
  await nftContract.deployed();

  console.log("Contract deployed to: ", nftContract.address);
  console.log("Contract deployed by: ", owner.address);

  let supply = await nftContract.totalSupply();
  console.log("The supply is", supply.toString());

  let txn = await nftContract.reserveNfts(50);
  await txn.wait()

  supply = await nftContract.totalSupply();
  console.log("The supply is", supply.toString());
};

// Test contract address: 

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  }
  catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();