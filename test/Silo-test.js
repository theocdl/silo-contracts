const {expect} = require("chai");

describe("Silo", function () {

    console.log(" ");

    //CONTRACT
    let DAI;
    let SILO;

    //CONTRACT DEPLOYER
    let dai;
    let silo;

    //ROLE
    let owner;
    let buyer;
    let company;

    beforeEach(async function () {

        [owner, buyer, company] = await ethers.getSigners();

        DAI = await ethers.getContractFactory("DAI");
        dai = await DAI.connect(owner).deploy();
        await dai.deployed();

        SILO = await ethers.getContractFactory("silo");
        silo = await SILO.connect(owner).deploy(dai.address);
        await dai.deployed();
    });


    describe("Deployment", function () {

        it("Contracts deployed", async function () {
            console.log("      ✔ DAI contract:",dai.address);
            console.log("      ✔ Silo contract:",silo.address);
        });

    });
    describe("Company registration", function () {
        it("Should register as a company", async function () {
            await silo.connect(company).addIssuer("Strat", "https://strat.cc");
            let nameCompagny = await silo.issuer('0');
            expect(nameCompagny.name).to.equal("Strat");
        });


        it("Should not be able to register twice", async function () {
            await silo.connect(company).addIssuer("Strat", "https://strat.cc");
            await expect(silo.connect(company).addIssuer("Strat", "https://strat.cc")).to.be.revertedWith("ISSUER_ALREADY_CREATED")
        });
    });

    describe("NFT creation and config", function () {

        it("Should create 10 NFTs", async function () {
            await silo.connect(company).addIssuer("Strat", "https://strat.cc");
            await silo.connect(company).create(0, 10, 100, "siloToken.json");
            let issuerinfo = await silo.issuer(0);
            let supply = issuerinfo.numItem;
            await expect(supply).to.equal('10');
        });

        it("Should modify the price of the NFTs for sale", async function () {
            await silo.connect(company).addIssuer("Strat", "https://strat.cc");
            await silo.connect(company).create(0, 1, 100, "siloToken.json");
            await silo.connect(company).changePrice(0, 90);
            let iteminfo = await silo.getItem(0);
            let price = iteminfo.price;
            await expect(price).to.equal('90');
        });

    });

    describe("DAI faucet", function () {
        it("Should receive 50 DAI", async function () {
            await dai.connect(buyer).withdraw();
            let buyerBalance = await dai.balanceOf(buyer.address);
            let buyerBlanceHex = buyerBalance.toString();
            expect(buyerBlanceHex).to.equal('50000000000000000000');
        });

    });

    describe("Buy NFT", function () {

        it("Should buy an NFT", async function () {
            let volume = ethers.utils.parseEther('100');

            await silo.connect(company).addIssuer("Strat", "https://strat.cc");
            await silo.connect(company).create(0, 1, 100, "siloToken.json");

            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();

            await dai.connect(buyer).approve(silo.address, volume);
            await silo.connect(buyer).buy(0);

            let buyerBalance = await silo.balanceOf(buyer.address);
            expect(buyerBalance).to.equal('1');
        });

        it("Should receive the money", async function () {
            let volume = ethers.utils.parseEther('100');

            await silo.connect(company).addIssuer("Strat", "https://strat.cc");
            await silo.connect(company).create(0, 1, 100, "siloToken.json");

            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();

            await dai.connect(buyer).approve(silo.address, volume);
            await silo.connect(buyer).buy(0);

            let buyerBalance = await dai.balanceOf(buyer.address);
            let buyerBalanceHex = buyerBalance.toString();
            expect(buyerBalanceHex).to.equal('50000000000000000000');
        });

        it("Should receive the money", async function () {
            let volume = ethers.utils.parseEther('100');

            await silo.connect(company).addIssuer("Strat", "https://strat.cc");
            await silo.connect(company).create(0, 1, 100, "siloToken.json");

            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();

            await dai.connect(buyer).approve(silo.address, volume);
            await silo.connect(buyer).buy(0);

            let companyBalance = await dai.balanceOf(company.address);
            let companyBalanceHex = companyBalance.toString();
            expect(companyBalanceHex).to.equal('100000000000000000000');
        });
    });

    describe("Redeem", function (){

        it("Should trigger the sell function", async function(){
            let volume = ethers.utils.parseEther('100');

            await silo.connect(company).addIssuer("Strat", "https://strat.cc");
            await silo.connect(company).create(0, 1, 100, "siloToken.json");

            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();

            await dai.connect(buyer).approve(silo.address, volume);
            await silo.connect(buyer).buy(0);

            await silo.connect(buyer).approve(company.address,0);
            await silo.connect(buyer).sell(0, "Strat", "newURI.json");

            let buyerBalance = await silo.balanceOf(buyer.address);
            expect(buyerBalance).to.equal('0');
        });

        it("Should transfer the NFT to the company", async function(){
            let volume = ethers.utils.parseEther('100');

            await silo.connect(company).addIssuer("Strat", "https://strat.cc");
            await silo.connect(company).create(0, 1, 100, "siloToken.json");

            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();

            await dai.connect(buyer).approve(silo.address, volume);
            await silo.connect(buyer).buy(0);

            await silo.connect(buyer).approve(company.address,0);
            await silo.connect(buyer).sell(0, "Strat", "newURI.json");

            let buyerBalance = await silo.balanceOf(company.address);
            expect(buyerBalance).to.equal('1');
        });

    });
});