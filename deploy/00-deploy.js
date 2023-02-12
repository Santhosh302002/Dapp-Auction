const { network, run } = require("hardhat")

module.exports = async ({ deployments, getNamedAccounts }) => {

    const { deployer } = await getNamedAccounts();
    const { deploy, log } = deployments;
    const chainId = network.config.chainId;
    if (chainId == 31337) {
        const contract = await deploy("Auction", {
            from: deployer,
            args: [],
            log: true
        }
        )
    }
}
module.exports.tags = ['all', 'mocks'];