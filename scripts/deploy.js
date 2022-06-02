const main = async () => {
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const topLevelDomain = "wagmi";
    const domainContract = await domainContractFactory.deploy(topLevelDomain);
    await domainContract.deployed();

    console.log("Contract deployed to:", domainContract.address);

    // CHANGE THIS DOMAIN TO SOMETHING ELSE! I don't want to see OpenSea full of bananas lol
    const domainName = "0xshinigami";
    const msg = "Trade my eyes for half of your remaining life.";

    let txn = await domainContract.register(domainName,  {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();
    console.log("Minted domain " + domainName + '.' + topLevelDomain);

    txn = await domainContract.setRecord(domainName, msg);
    await txn.wait();
    console.log("Set record for " + domainName);

    const address = await domainContract.getAddress("banana");
    console.log("Owner of domain " + domainName + ": " + address);

    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
}

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();