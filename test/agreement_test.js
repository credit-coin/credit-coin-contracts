const Agreement = artifacts.require('./Agreement.sol');
const moment = require('moment');
const testFixtures = require('./fixtures');
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
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

    it('should add new content', async () => {
        await agreement.addContent(...testFixtures.newContent, {from: brand, value: 10});
        const content = await agreement.getContentByName(testFixtures.newContent[0])
        assert.equal(content[0], testFixtures.newContent[0])
        assert.equal(content[1], testFixtures.newContent[1])
        assert.equal(content[2].toString(), 10+"")
        assert.equal(await web3.eth.getBalance(agreement.address).toString(10), 10+"")
    })

    it('should fulfillDeliverable by creator', async () => {
        const id = web3.sha3(testFixtures.newContent[0])
        await agreement.fulfillDeliverable(id, {from: creator});
        const isFulfilled = await agreement.currentFulfillment(testFixtures.newContent[0], {from: creator});
        assert.equal(isFulfilled, true);
    })

    it('should approveDeliverable by brand', async () => {
        const id = web3.sha3(testFixtures.newContent[0])
        await agreement.approveDeliverable(id, {from: brand});
        const isFulfilled = await agreement.currentFulfillment(testFixtures.newContent[0], {from: brand});
        assert.equal(isFulfilled, true);
    })

    it('should lock deliverable', async () => {
        await agreement.lock({from: brand});
        assert.equal( await agreement.locked(), true);
    })

    it('should complete deliverable and transfer funds', async () => {
        const agreementPrevBal = await web3.eth.getBalance(brand).toString();
        await agreement.addContent("Complete This", "will Be Completed", 1000, {from: brand, value: 1000});
        await agreement.approveDeliverable(id, {from: brand});
        await agreement.fulfillDeliverable(id, {from: creator});
    })
});
