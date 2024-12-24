const hre = require("hardhat");

async function deploy(){
    const Escrow = await hre.ethers.getContractFactory("Escrow");

    const Counter = await hre.ethers.getContractFactory("Counter");
    const counter = await Counter.deploy();
    await counter.deployed();
    
    return counter;
}

async function count(counter){
    console.log("Counter  count ",await counter.count());
    console.log("Counter  getCount",await counter.getCount());
}

deploy().then(count);