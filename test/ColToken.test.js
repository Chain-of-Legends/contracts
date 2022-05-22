const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');
//const { BN} = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

contract("ColToken", (accounts) => {
  const [deployer, other] = accounts;

  const _name = "Chain of Legends Token";
  const _symbol = "CLEG";
  const _decimals = new BN(18);
  const _totalSupply = 1000000000 * 10 ** 18;
  const _giveAmount = new BN(10).pow(new BN(24));

  before(async function () {
    this.token = await require('../migrations/1_initial_migration')();
    //this.token = await ColToken.new(_name, _symbol);
    //await this.token.initialize(_name, _symbol);
  });

  describe('token attributes', function () {

    it('has the correct name', async function () {
      const name = await this.token.name();
      expect(name).to.equal(_name);
    });
    it('has the correct symbols', async function () {
      const symbol = await this.token.symbol();
      expect(symbol).to.equal(_symbol);
    });
    it('has the correct decimals', async function () {
      const decimals = await this.token.decimals();
      expect(decimals).to.be.bignumber.equal(_decimals);
    });

    it('has the correct total supply', async function () {
      const totalSupply = await this.token.totalSupply();
      expect(+totalSupply.toString()).to.equal(_totalSupply);
    });

    it('contract has all total supply', async function () {
      const bal = await this.token.balanceOf(this.token.address);
      expect(+bal.toString()).to.equal(_totalSupply);
    });

    it('give method', async function () {
      let owner = await this.token.owner();
      // this.token.approve(this.token.address,_giveAmount);
      // this.token.approve(owner,_giveAmount);
      // await this.token.twoSideApprove(owner, this.token.address, _giveAmount);
      await this.token.twoSideApprove(this.token.address, owner , _giveAmount);
      //console.log("allowance is ", +allowance);
      await this.token.give(owner, _giveAmount);
      const bal = await this.token.balanceOf(owner);

      expect(+bal.toString()).to.equal(+_giveAmount.toString());
    });

    
    it('distribute method', async function () {
      var receprients= [
        "0xd6848eC6CA96b5e86C459179A3970646D6ad02A8",
        "0xda03C3687934fF4912b6eC299D509FB1dE4e679E",
        "0x14505215377eF9fE73343941e6BB6Ed78B634247",
        "0x687Fc49CD772A2B53AFe090830ED6Fc74c9B8E8B",
        "0x651728a43e407eeed8df516B448b711F6f6c3acD",];

      var values = [
        new BN(10).pow(new BN(18)).div(new BN(100)).mul(new BN(1)),
        new BN(10).pow(new BN(18)).div(new BN(100)).mul(new BN(2)),
        new BN(10).pow(new BN(18)).div(new BN(100)).mul(new BN(3)),
        new BN(10).pow(new BN(18)).div(new BN(100)).mul(new BN(4)),
        new BN(10).pow(new BN(18)).div(new BN(100)).mul(new BN(5))];

      var totalDistribution = new BN(0);
      for (let i = 0; i < values.length; i++) {
        totalDistribution = totalDistribution.add(values[i])
      }
      let owner = await this.token.owner();
      await this.token.twoSideApprove(this.token.address, owner , totalDistribution);

      await this.token.distribute(receprients, values);
      for (let i = 0; i < receprients.length; i++) {
        const bal = await this.token.balanceOf(receprients[i]);
        expect(+bal.toString()).to.equal(+values[i].toString());
      }

    });
  })
})