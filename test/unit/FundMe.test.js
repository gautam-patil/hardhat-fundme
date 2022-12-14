const { assert, expect }= require("chai");
const { deployments, ethers, getNamedAccounts } = require("hardhat");
const { developmentChain } = require("../../helper-hardhat-config");

!developmentChain.includes(network.name)
	? 	describe.skip
	:   describe("FundMe", async function () {

			let fundMe;
			let deployer;
			let mockV3Aggregator;
			const sendValue = ethers.utils.parseEther("1") //1 ETH
			beforeEach(async function () {

				// const accounts = await ethers.getSigners()
				// const accountZero = accounts[0]
				deployer = (await getNamedAccounts()).deployer
				await deployments.fixture(["all"])
				fundMe = await ethers.getContract("FundMe", deployer)
				mockV3Aggregator = await ethers.getContract("MockV3Aggregator", deployer)
			})
			describe("constructor", async function () {
				it("sets the aggregator address correctly", async function () {
					const response = await fundMe.getPriceFeed();
					assert.equal(response, mockV3Aggregator.address)
				})
			})

			describe("fund", async function () {
				it("Fails if you don't send enough ETH", async function () {
					await expect(fundMe.fund()).to.be.revertedWith(
						"Didn't send enough!!"
					)
				})

				it("Updated the amount funded data structure", async function () {
					await fundMe.fund({ value: sendValue })
					const response = await fundMe.getAddressToAmountFunded(
						deployer
					)

					assert.equal(response.toString(), sendValue.toString())
				})
			})
		})