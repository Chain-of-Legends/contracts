var addresses = ["0xd3A6BBA8407305EFA3f479a3784c13F72c7006F3","0x45aB41a6904De61Ea2334E21Ccd5AF603631869c"]

var prizes =[500000,10000]

const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');
const { web3 } = require('@openzeppelin/test-helpers/src/setup');

var sumPrize = 0;
for (let i = 0; i < prizes.length; i++) {
  sumPrize+= prizes[i];
  prizes[i] = web3.utils.toWei(prizes[i].toString());
  
}

module.exports = async function (deployer) {
  const ColToken = artifacts.require('ColToken');
  var instance = await ColToken.at("0xaa0ce9adaf3c473682b2bd12bd1d7a5195a1832e");//0x46f21C3DA7Dedc23AD52C26642b6a41b4ffd6a19");//"0xaa0ce9adaf3c473682b2bd12bd1d7a5195a1832e");//"0x4027d91eCD3140e53AE743d657549adfeEbB27AB");
  
  if(addresses.length != prizes.length)
    return console.log("Addresses and prizes count are not equal");

  var expectedBalance = web3.utils.toWei("800000000");
  var giveAmount = web3.utils.toWei(sumPrize.toString());
  var owner = await instance.owner();
  var bal = await instance.balanceOf(instance.address);
  console.log("Owner: ", owner, " Balance: ", +bal);

var totalPrize = 0;
for (let i = 0; i < prizes.length; i++) 
  totalPrize+= prizes[i];

  await instance.distribute(addresses,prizes,totalPrize);
  // if (+bal == expectedBalance){
  // }else
  // {
  //   console.log(+bal ," != ", expectedBalance);
  // }

  for (let i = 0; i < addresses.length; i++) {
    const bal = await instance.balanceOf(addresses[i]);
    console.log(web3.utils.fromWei(bal.toString()));
  }

  console.log("Deployed. Address: ", instance.address, 
    "\n Name: ", await instance.name(),
    "\n Owner: ", await instance.owner(),
    "\n Owner Balance: ", +(await instance.balanceOf(await instance.owner())),
    "\n Owner Balance: ", +(await instance.balanceOf(instance.address)));
  return instance;
}