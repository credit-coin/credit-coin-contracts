const Agreement = artifacts.require('./Agreement.sol');
const moment = require('moment');

contract('AgreementTest', (accounts) => {
    let agreement,
        brand,
        creator,
        expiration;
    //create new smart contract instances before each test method
    before(async () => {
        brand = accounts[0];
        creator = accounts[1]
        expiration = moment().add(1, 'days').unix().valueOf();
        agreement = await Agreement.new(creator, expiration, {from: brand});
    });

    it('should set correct initial values', async () => {
        assert.equal(await agreement.brand(), brand);
        assert.equal(await agreement.creator(), creator);
        assert.equal(parseInt(await agreement.expiration()), expiration);
    })
});
