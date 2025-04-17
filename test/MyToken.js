const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyToken", function () {
    let MyToken, myToken, owner, addr1, addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        MyToken = await ethers.getContractFactory("MyToken");
        myToken = await MyToken.deploy(owner.address);
        console.log(owner);
        console.log(addr1);
        console.log(addr2);
    });

    it("應該有正確的名稱和符號", async function () {
        expect(await myToken.name()).to.equal("MyToken");
        expect(await myToken.symbol()).to.equal("MTK");
    });

    it("應該允許擁有者鑄造代幣", async function () {
        await myToken.mint(addr1.address, 500);
        expect(await myToken.balanceOf(addr1.address)).to.equal(500);
    });

    it("應該允許用戶轉帳", async function () {
        await myToken.transfer(addr1.address, 100);
        expect(await myToken.balanceOf(addr1.address)).to.equal(100);
    });

    it("應該應用交易稅", async function () {
        await myToken.transfer(addr1.address, 1000);
        await myToken.connect(addr1).transfer(addr2.address, 1000);
        expect(await myToken.balanceOf(addr2.address)).to.be.closeTo(980, 1); // 2% 稅
    });

    it("應該允許銷毀代幣", async function () {
        await myToken.mint(addr1.address, 500);
        await myToken.connect(addr1).burn(200);
        expect(await myToken.balanceOf(addr1.address)).to.equal(300);
    });

    it("應該允許批量轉帳", async function () {
        const recipients = [addr1.address, addr2.address];
        const amounts = [100, 200];

        await myToken.batchTransfer(recipients, amounts);

        expect(await myToken.balanceOf(addr1.address)).to.equal(100);
        expect(await myToken.balanceOf(addr2.address)).to.equal(200);
    });

    it("手續費設定正確", async function () {

        await myToken.setTaxRate(9);

        expect(await myToken.taxRate()).to.be.below(10); // 2% 稅

    });
});
