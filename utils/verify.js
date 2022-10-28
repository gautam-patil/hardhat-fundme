const { run } = require("hardhat");

const verify = async (contractAddress, args) => {
	console.log("Verifing.....")

	try{
		await run("verify:verify", {
			address: contractAddress,
			constructorArguments: args,
		})
	}catch(e){
		if(e.message.toLowerCase().includes("Already Verified")) {
			console.log("Already Verified")
		}else{
			console.log(e)
		}
	}
}

module.exports = { verify }