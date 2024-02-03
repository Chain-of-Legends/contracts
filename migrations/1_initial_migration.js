const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

//const ColTokenV2 = artifacts.require('ColTokenV2');

module.exports = async function (deployer) {
  const ColToken = artifacts.require('ColToken');
  const _name = "Chain of Legends Token";
  const _symbol = "CLEG";
  var instance = null;
  
  try {
    instance = await ColToken.at("0x4027d91eCD3140e53AE743d657549adfeEbB27AB");//,0x4027d91eCD3140e53AE743d657549adfeEbB27AB"0xaa0ce9adaf3c473682b2bd12bd1d7a5195a1832e");//.deployed();
  } catch (error) {
    console.log(error)
  }
  
  if(!instance){
    console.log("Contract NOT existed. Deploying new one.")
    instance = await deployProxy(ColToken, [_name,_symbol]);
  }
  else{
    console.log("Upgrading existing ColToken contract.")
    instance = await upgradeProxy(instance.address,ColToken,[_name,_symbol]);
  }

  console.log("Deployed. Address: ", instance.address, 
    "\n Name: ", await instance.name(),
    "\n Owner: ", await instance.owner(),
    "\n Owner Balance: ", +(await instance.balanceOf(await instance.owner())));
  return instance;
}