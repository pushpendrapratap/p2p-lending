const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    const ChitFundContract = await hre.ethers.getContractFactory("ChitFund");
    const chitFundContract = await ChitFundContract.deploy();

    await chitFundContract.deployed();
    console.log("chitFund Contract address:", chitFundContract.address);

    // saveFrontendFiles(chitFundContract);
}

function saveFrontendFiles(contract) {
    const fs = require("fs");
    const contractsDir = __dirname + "/../src/abis";

    if (!fs.existsSync(contractsDir)) {
        fs.mkdirSync(contractsDir);
    }

    fs.writeFileSync(
        contractsDir + "/contract-address.json",
        JSON.stringify({ ChitFundContract: contract.address }, undefined, 2)
    );

    const ChitFundContractArtifact =
        hre.artifacts.readArtifactSync("ChitFundContract");

    fs.writeFileSync(
        contractsDir + "/ChitFundContract.json",
        JSON.stringify(ChitFundContractArtifact, null, 2)
    );
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log(error);
        process.exit(1);
    });
