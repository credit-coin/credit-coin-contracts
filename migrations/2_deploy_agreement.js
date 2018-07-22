const Agreement = artifacts.require('./Agreement.sol');
const ContentUtils = artifacts.require('./ContentUtils.sol');
const Token = artifacts.require('tokencontract/contracts/CCOIN.sol');
const moment = require('moment');

module.exports = async (deployer, network, accounts) => {
    deployer.then(async () => {
        await deployer.deploy(Token); 
        const token = Token.deployed();
        await deployer.deploy(ContentUtils);
        await deployer.link(ContentUtils, [Agreement]);
    });
};