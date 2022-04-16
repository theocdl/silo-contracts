const {expect} = require("chai");

describe("ERC1155 token", function () {
//CONTRACT
    let DAI;
    let SILO;

//CONTRACT DEPLOYER
    let dai;
    let silo;

//ROLE
    let owner;
    let buyer;
    let holder;

    beforeEach(async function () {

        [owner, buyer, holder] = await ethers.getSigners();

        DAI = await ethers.getContractFactory("DAI");
        dai = await DAI.connect(owner).deploy();
        await dai.deployed();

        SILO = await ethers.getContractFactory("silo");
        silo = await SILO.connect(owner).deploy(dai.address);
        await dai.deployed();
    });


    describe("Deployment", function () {

        it("Should contract be deployed", async function () {
            console.log(" ");
            console.log("DAI contract : ", dai.address);
            console.log("Silo contract : ", silo.address);
            console.log(" ");
        });

    });
    describe("Create compagne", function () {
        it("Should holder can create a compagny", async function () {
            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            let nameCompagny = await silo.issuer('0');
            expect(nameCompagny.name).to.equal("Strat");
        });


        it("You can't recreate an existing compagny", async function () {
            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            await expect(silo.connect(holder).addIssuer("Strat", "https://strat.cc")).to.be.revertedWith("Your Issuer has already been created !")
        });
    });

    describe("Create and modify the certificate", function () {

        it("Compagny  register can  create 10 Certificates", async function () {
            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            await silo.connect(holder).create(0, 1, 100, 10);
            let iteminfo = await silo.getItem(0, 1);
            let supply = iteminfo.supply;
            await expect(supply).to.equal('10');
        });

        it("Holder of the compagny can change the price of the certificate", async function () {
            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            await silo.connect(holder).create(0, 1, 100, 1);
            await silo.connect(holder).changePrice(0, 1, 90);
            let iteminfo = await silo.getItem(0, 1);
            let price = iteminfo.price;
            await expect(price).to.equal('90');
        });

        it("Holder of the compagny can change the supply of the certificate", async function () {
            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            await silo.connect(holder).create(0, 1, 100, 1);
            await silo.connect(holder).changeSupply(0, 1, 2);
            let iteminfo = await silo.getItem(0, 1);
            let supply = iteminfo.supply;
            await expect(supply).to.equal('2');
        });
    });

    describe("Get DAI", function () {
        it("Buyer can receive 50 DAI", async function () {
            await dai.connect(buyer).withdraw();
            let buyerBalance = await dai.balanceOf(buyer.address);
            let buyerBlanceHex = buyerBalance.toString();
            expect(buyerBlanceHex).to.equal('50000000000000000000');
        });

    });

    describe("Buy certificate", function () {

        it("Buyer can buy a certificate", async function () {
            let volume = ethers.utils.parseEther('100');

            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            await silo.connect(holder).create(0, 1, 100, 1);

            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();

            await dai.connect(buyer).approve(silo.address, volume);
            await silo.connect(buyer).buy(0, 1, 1);

            let buyerBalance = await silo.balanceOf(buyer.address, 0);
            expect(buyerBalance).to.equal('1');
        });

        it("Buyer send the money to the Holder", async function () {
            let volume = ethers.utils.parseEther('100');

            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            await silo.connect(holder).create(0, 1, 100, 1);

            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();

            await dai.connect(buyer).approve(silo.address, volume);
            await silo.connect(buyer).buy(0, 1, 1);

            let buyerBalance = await dai.balanceOf(buyer.address);
            let buyerBalanceHex = buyerBalance.toString();
            expect(buyerBalanceHex).to.equal('50000000000000000000');
        });

        it("Holder receive the money to the Buyer", async function () {
            let volume = ethers.utils.parseEther('100');

            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            await silo.connect(holder).create(0, 1, 100, 1);

            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();
            await dai.connect(buyer).withdraw();

            await dai.connect(buyer).approve(silo.address, volume);
            await silo.connect(buyer).buy(0, 1, 1);

            let holderBalance = await dai.balanceOf(holder.address);
            let holderBalanceHex = holderBalance.toString();
            expect(holderBalanceHex).to.equal('100000000000000000000');
        });
    });
});