
const BTEMSale = artifacts.require("BTEMSale");
const Web3 = require("web3");
var web3 = new Web3('https://polygon-mainnet.infura.io/v3/5753894cae05439987bf8c379a717289');

module.exports = async function (deployer) {
  await deployer.deploy(BTEMSale, 
                        60, 
                        "0x0e17979Ee4003047Ca605Bc346C6825cCB856516", 
                        "0x28332c6AFB5100D9a9b82844FE29ff6884223c6b", 
                        1639155600,
                        1641834000,
                        web3.utils.toWei("50000", "ether"));
  //await token.transfer(sale.address, web3.utils.toWei("3000000", "ether"), {from: "0x0e17979Ee4003047Ca605Bc346C6825cCB856516"});



};