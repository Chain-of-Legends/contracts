const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');
const { web3 } = require('@openzeppelin/test-helpers/src/setup');

module.exports = async function (deployer) {
  const ColToken = artifacts.require('ColToken');
  var instance = await ColToken.at("0x4027d91eCD3140e53AE743d657549adfeEbB27AB");
  
  var expectedBalance = web3.utils.toWei("1000000000");
  var giveAmount = web3.utils.toWei("200000000");
  var owner = await instance.owner();
  var bal = await instance.balanceOf(instance.address);
  console.log("Owner: ", owner, " Balance: ", +bal);
  if (+bal == expectedBalance){
    //ColToken.twoSideApprove(owner,instance.address, giveAmount);
    ColToken.give(owner, giveAmount);
  }

  console.log("Deployed. Address: ", instance.address, 
    "\n Name: ", await instance.name(),
    "\n Owner: ", await instance.owner(),
    "\n Owner Balance: ", +(await instance.balanceOf(await instance.owner())),
    "\n Owner Balance: ", +(await instance.balanceOf(instance.address)));
  return instance;
}