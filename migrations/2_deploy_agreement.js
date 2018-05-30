const Agreement = artifacts.require('./Agreement.sol');
const ContentUtils = artifacts.require('./ContentUtils.sol');
const moment = require('moment');

module.exports = async (deployer, network, accounts) => {
    await deployer.deploy(ContentUtils);
    await deployer.link(ContentUtils, [Agreement]);
    await deployer.deploy(Agreement, accounts[1], moment().add(1, 'days').unix().valueOf(), {from: accounts[0]});
};