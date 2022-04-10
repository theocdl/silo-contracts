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
    describe("Silo test", function () {
        it("Should holder can create a compagny", async function () {
            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            let nameCompagny = await silo.issuer('0');
            expect(nameCompagny.name).to.equal("Strat");
        });

        it("You can't recreate an existing compagny", async function () {
            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            await expect(silo.connect(holder).addIssuer("Strat", "https://strat.cc")).to.be.revertedWith("Your Issuer has already been created !")
        });

        it("Compagny  register can  create 10 Certificates", async function () {
            await silo.connect(holder).addIssuer("Strat", "https://strat.cc");
            await silo.connect(holder).create(0, 1, 100, 10);
            let iteminfo = await silo.getItem(0,1);
            let supply = iteminfo.supply;
            await  expect(supply).to.equal('10');

        });

    });

});