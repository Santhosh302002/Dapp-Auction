// const { verify } = require("crypto");
const { network, run } = require("hardhat");
const { networkConfig } = require("../helper.hardhat.config");


module.exports = async ({ deployments, getNamedAccounts }) => {
    const { deployer } = await getNamedAccounts();
    const { deploy, log } = deployments;
    const chainId = network.config.chainId;
    const args = [
        networkConfig[chainId]["vrfCoordinatorV2"],
        networkConfig[chainId]["gasLane"],
        networkConfig[chainId]["subscriptionId"],
        networkConfig[chainId]["callbackGasLimit"]
    ]
    if (chainId == "5") {
        const contract = await deploy("Auction", {
            from: deployer,
            args: args,
            log: true
        }
        )
        await verify(contract.address, args);
    }

}

const verify = async (contractAddress, args) => {
    console.log("Verifying contract...")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already verified!")
        } else {
            console.log(e)
        }
    }
}
module.exports.tags = ['all', 'Auction'];