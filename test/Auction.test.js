const { getContractFactory } = require("@nomiclabs/hardhat-ethers/types")
const { assert, expect } = require("chai")
const { ContractFactory } = require("ethers")
const { getNamedAccounts, ethers, network } = require("hardhat")
const { describe, beforeEach } = require("node:test")

if (network.config.chainId == 31337) {
    describe("Owner Product Update", function () {
        let contract, transcation
        beforeEach(async () => {
            contract = await getContractFactory("Auction")
            transcation = await contract.deploy()
        }
        )
    })
}