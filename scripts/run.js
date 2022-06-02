
const main = async () => {
    //hre: Hardhat Runtime Environment, ie, the object containing all functionality of Hardhat.
    //So what does this mean? Every time you run a terminal command that starts with npx hardhat
    // you are getting this hre object built on the fly using the hardhat.config.js specified in your code!
    // This means you will never have to actually do some sort of import into your files
    const [owner, randomAccount] = await hre.ethers.getSigners();

    //Compiles our solidity contract
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');

    //Deploys it to the chain configured in hardhat.config.js
    const domainContract = await domainContractFactory.deploy("wagmi");

    //Wait till the contract is mined and deployed to the local blockchain especially created for this account
    //which will be destroyed once this script completes
    await domainContract.deployed();
    console.log("Contract deployed to: " + domainContract.address);
    console.log("Contract deployed by:" + owner.address);
    console.log("What the hell is account: " + randomAccount.address);

    //Second variable is how we pass money to the payable contract from
    let txn = await domainContract.register("0xshinigami", {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();

    const domainAddress = await domainContract.getAddress("0xshinigami");
    console.log("Address for domain name 0xshinigami: " + domainAddress);

    //Lets check the smart contract balance
    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract bal: " + hre.ethers.utils.formatEther(balance));

    // txn = await domainContract.connect(randomAccount).setRecord("0xshinigami", "Setting domain w/o being the
    // sender, should revert.");
    // await txn.wait();

};

const runMain = async() => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();