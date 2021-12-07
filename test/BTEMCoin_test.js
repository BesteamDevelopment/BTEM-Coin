const BTEMCoin = artifacts.require("BTEMCoin");
const BTEMSale = artifacts.require("BTEMSale");

contract("BTEMCoin testing", async => {
    /*
    it("Should initialize the contract", async () => {
        const instance = await BTEMCoin.new();
        const balance = await instance.balanceOf("0xf4946550bbA675FbAdbfd694197B203839798B50");
        console.log(balance.toNumber());
        assert.equal(true. true, "The balance is not the same");
    });
    */

    it("Should deploy BTEM sale", async () => {
        const instance = await BTEMSale.new();
        console.log(instance)

    })

    /*
    it("Should transfer token from master to other account", async() => {
        const instance = await BTEMCoin.new();
        const sale = await BTEMSale.new();

        await instance.setMaxTxAmount(web3.utils.toWei("10000000", "ether"), {from: "0x7478Ee1125490E3fD8eCCBF9860c749174103247"});
        await instance.transfer(sale.address, 3000000, {from: "0x7478Ee1125490E3fD8eCCBF9860c749174103247"});

        const balance = await instance.balanceOf(sale.address, {from:"0x7478Ee1125490E3fD8eCCBF9860c749174103247"});
        console.log(balance.toNumber());
        
        assert.equal(true, true, "The balance is not correct - 100");
    })
    */
})