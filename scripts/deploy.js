const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners(); //取得目前帳號（錢包）列表，並把第一個帳號設為 deployer
    console.log("Deploying contracts with account:", deployer.address);

    const MyToken = await ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy(deployer.address); //部署合約，呼叫 MyToken合約的constructor，並輸入參數

    console.log("MyToken deployed to:", myToken.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
