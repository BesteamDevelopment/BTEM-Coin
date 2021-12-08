const tokenJson = require("./build/contracts/BTEMCoin.json");
const saleJson = require("./build/contracts/BTEMSale.json");

const Web3 = require("web3");
const web3 = new Web3(new Web3.providers.HttpProvider("https://polygon-mainnet.infura.io/v3/5753894cae05439987bf8c379a717289"))

async function main(){
    console.log(tokenJson.bytecode);
    /*const token = new web3.eth.Contract(tokenJson.abi, "0x90A865Ec2215c5D1F9AA8Bd487b5DA5C31A4D41B");
    const sale = new web3.eth.Contract(saleJson.abi);
//console.log(saleJson.bytecode);
    let payload = {
        data: saleJson.bytecode,
        arguments: [
            60, 
            "0x0e17979Ee4003047Ca605Bc346C6825cCB856516", 
            "0x28332c6AFB5100D9a9b82844FE29ff6884223c6b", 
            1639155600,
            1641834000,
            web3.utils.toWei("50000", "ether")
        ]
    }
    let sa = await sale.deploy(payload).estimateGas({from: "0x0e17979Ee4003047Ca605Bc346C6825cCB856516"})
    console.log(sa);
    //const marketFee = await token.methods.marketFee().call();
    
    /*
    const bal1 = await token.methods.balanceOf("0x0278aA1Bf268Ad72dB892707cDd2A1c3C8dBFbF5").call({from:"0x7478Ee1125490E3fD8eCCBF9860c749174103247"})
    console.log("Marketing: ", bal1);

    const bal2 = await token.methods.balanceOf("0x43Ab1cD59E58830718737322a8134606eD25f1DE").call({from:"0x7478Ee1125490E3fD8eCCBF9860c749174103247"})
    console.log("Dev: ", bal2);

    const bal3 = await token.methods.balanceOf("0x43Ab1cD59E58830718737322a8134606eD25f1DE").call({from:"0x7478Ee1125490E3fD8eCCBF9860c749174103247"})
    console.log("LP: ",bal3);
*/
    //await token.methods.setTakeFee(true).send({from: "0x7478Ee1125490E3fD8eCCBF9860c749174103247"});
    /*
    await token.methods.changeWalletAddress(1, "0x8Fe74a62239437669440b8F18C5FF70ed3ACe4B6").send({from:"0x7478Ee1125490E3fD8eCCBF9860c749174103247"})

    await token.methods.changeWalletAddress(2, "0x565B5b0fC4b42f5B71c6f795D1A26582bB6f6Cf6").send({from:"0x7478Ee1125490E3fD8eCCBF9860c749174103247"})

    await token.methods.changeWalletAddress(3, "0x863AD0A5314A8E3e21065ad0A23ED63dFb9fd9A6").send({from:"0x7478Ee1125490E3fD8eCCBF9860c749174103247"})
    */
}

main();


/*
token.methods.getMaxTxAmount().call({from:"0x0278aA1Bf268Ad72dB892707cDd2A1c3C8dBFbF5"})
.then(function(result){
    console.log(web3.utils.fromWei(result, "ether"))
});
*/
