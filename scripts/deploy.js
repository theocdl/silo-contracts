// npx hardhat run --network goerli scripts/deploy.js

const hre = require("hardhat");

async function main() {

    DAI = await hre.ethers.getContractFactory("DAI");
    dai = await DAI.deploy();
    await dai.deployed();
    console.log("Deployed to:", dai.address);

    const Silo = await hre.ethers.getContractFactory("Silo");
    const silo = await Silo.deploy();
    await silo.deployed();
    console.log("Deployed to:", silo.address);
    // TODO: wait 5 confirmations

    // https://docs.ethers.io/v5/api/providers/types/#providers-TransactionResponse

    // NomicLabsHardhatPluginError: Failed to send contract verification request.
    // Endpoint URL: https://api-rinkeby.etherscan.io/api
    // Reason: The Etherscan API responded that the address 0xbc1E2bE38412a09be29f00794ae9916144c858BE does not have bytecode.
    // This can happen if the contract was recently deployed and this fact hasn't propagated to the backend yet.
    // Try waiting for a minute before verifying your contract. If you are invoking this from a script,
    // try to wait for five confirmations of your contract deployment transaction before running the verification subtask.

    await hre.run("verify", {network: "goerli", address: silo.address});
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});