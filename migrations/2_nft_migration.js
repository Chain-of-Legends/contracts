const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer, network) {
  const _contract = artifacts.require("ColNft");
  var instance = null;

  console.log("DEPLOYER:", deployer);
  console.log("NETWORK:", network);

  var contractAddress;
  if (network == "bsc")
    contractAddress = "0xdF710790ca64B4074366D9ce8d29d4D435a251f4";
  // else if (network == "testnet")
  //   contractAddress = "0x7E8C6850082B8c4331fE2f777D6bE3A8A06AB0e1"
  else if (network == "development")
    contractAddress = "0xc45720B0C82527bF45d479B650eeD32c1E3B0D4F";

  if (contractAddress)
    instance = await upgradeProxy(contractAddress, _contract, { deployer });
  else
    instance = await deployProxy(_contract);
  // try {
  //   instance = await _contract.deployed();
  // } catch (error) {
  //   console.log(error)
  // }

  // if(!instance){
  //   console.log("Contract NOT existed. Deploying new one.")
  //   instance = await deployProxy(_contract);
  // }
  // else{
  //   console.log("Upgrading existing ColNFT contract. Accounts: ", await web3.eth.getAccounts())
  //   instance = await upgradeProxy(instance.address,_contract,{deployer});
  // }

  console.log("Deployed. Address: ", instance.address,
    "\n Name: ", await instance.name(),
    "\n Owner: ", await instance.owner(),
    "\n Owner Balance: ", +(await instance.balanceOf(await instance.owner())));
  return instance;
}