const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');
const { web3 } = require('@openzeppelin/test-helpers/src/setup');

module.exports = async function (deployer) {
  const ColNft = artifacts.require('ColNft');
  var instance = await ColNft.at("0xdF710790ca64B4074366D9ce8d29d4D435a251f4");
  
  // var giveAmount = web3.utils.toWei("6250000");
  // var owner = await instance.owner();
  instance.setApprovalForAll( "0x9288827002B57D5B0B36E131eb1d48f25650a60B", true);
  //await instance.twoSideApprove(owner, "0x9288827002B57D5B0B36E131eb1d48f25650a60B", giveAmount);

  console.log("Deployed. Address: ", instance.address, 
    "\n Name: ", await instance.name(),
    "\n Owner: ", await instance.owner(),
    "\n Owner Balance: ", +(await instance.balanceOf(await instance.owner())),
    "\n Owner Balance: ", +(await instance.balanceOf(instance.address)));
  return instance;
}