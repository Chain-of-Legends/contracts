const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');
const { web3 } = require('@openzeppelin/test-helpers/src/setup');

module.exports = async function (deployer, network) {
  console.log("1");
  const ColNFT = artifacts.require('ColNFT');
  var contractAddress;
  // if (network == "testnet")
  //   contractAddress = "0xc854175B2053B56b28E0F256B78f543E094375a1";
  // if (network == "bsc")
     contractAddress = "0xdF710790ca64B4074366D9ce8d29d4D435a251f4";
  // if (network == "development")
  //  contractAddress = "0xc45720B0C82527bF45d479B650eeD32c1E3B0D4F";
    

    console.log("contract: ", contractAddress);
  var instance = await ColNFT.at(contractAddress);
  console.log("Deployed. Address: ", instance.address,
    "\n Name: ", await instance.name(),
    "\n Owner: ", await instance.owner());

  await instance.mintGenesisBoxes(501, 504);
  // await instance.mintGenesisBoxes(551, 600);
  // await instance.mintGenesisBoxes(601, 650);
  // await instance.mintGenesisBoxes(651, 700);
  // await instance.mintGenesisBoxes(701, 715);

  console.log(501,await instance.tokenURI(501));
  console.log(600,await instance.tokenURI(600));
  console.log(601,await instance.tokenURI(601));
  console.log(670,await instance.tokenURI(670));
  console.log(671,await instance.tokenURI(671));
  console.log(700,await instance.tokenURI(700));
  console.log(701,await instance.tokenURI(701));
  console.log(715,await instance.tokenURI(715));

  console.log("DONE");
  return instance;
}