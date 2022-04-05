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

});