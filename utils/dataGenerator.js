const { ethers } = require('ethers');
const fs = require('fs');

async function generateWallets() {
    const wallets = [];
    const numWallets = 500;

    for (let i = 0; i < numWallets; i++) {
        const wallet = ethers.Wallet.createRandom();
        wallets.push(wallet);
    }

    return wallets;
}

generateWallets().then(wallets => {
    console.log("Generated Wallet Addresses:");
    wallets.forEach((wallet, index) => {


        fs.appendFile('./scripts/airdrop_data.csv',`${wallet.address},2000000000,${index}\n`, function (err) {
            if (err) {
              // append failed
            } else {
              // done
            }
          })
    });
    console.log("-----------done------------------");
}).catch(error => {
    console.error("Error generating wallets:", error);
});
