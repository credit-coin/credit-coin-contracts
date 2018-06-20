const Agreement = artifacts.require('./Agreement.sol');
const Token = artifacts.require('tokencontract/contracts/CCOIN.sol');
const abi = require('tokencontract').abi;

const moment = require('moment');
const testFixtures = require('./fixtures');
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:9545"));
contract('AgreementTest', (accounts) => {
    let agreement,
        brand,
        creator,
        expiration,
        token;
    //create new smart contract instances before each test method
    
    before(async () => {
        brand = accounts[0];
        creator = accounts[1]
        expiration = moment().add(30, 'days').unix().valueOf();
        token = await Token.new({from: brand});
        agreement = await Agreement.new(creator, expiration, token.address, {from: brand});
    });

    it('should set correct initial values', async () => {
        assert.equal(await agreement.brand(), brand);
        assert.equal(await agreement.creator(), creator);
        assert.equal(parseInt(await agreement.expiration()), expiration);
    })

    it('should add new content', async () => {
        await token.transfer(agreement.address, testFixtures.newContent[2], {from: brand});
        await agreement.addContent(...testFixtures.newContent, {from: brand});
        const content = await agreement.getContentByName(testFixtures.newContent[0])
        const balance = await agreement.currentBalance();
        assert.equal(content[0], testFixtures.newContent[0])
        assert.equal(content[1], testFixtures.newContent[1])
        assert.equal(content[2].toString(), 10+"")
        assert.equal(balance.toString(10), 10+"")
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

    it('should complete deliverable update agreement balance and make reward claimable', async () => {
        const reward = 1000,
            name = "CompleteThis",
            description = "will Be Completed";
        const agreementPrevBal = await agreement.currentBalance();
        const agreementPrevClaimable = await agreement.claimable();

        await token.transfer(agreement.address, reward+parseInt(agreementPrevBal.toString(10)), {from: brand});
        await agreement.addContent(name, description, reward, {from: brand});

        const balance = await agreement.currentBalance();
        const expectedBalance = parseInt(agreementPrevBal.toString(10))+parseInt(reward.toString(10));
        assert.equal(balance.toString(10), expectedBalance.toString(10));

        const id = web3.sha3(name);
        await agreement.fulfillDeliverable(id, {from: creator});
        await agreement.approveDeliverable(id, {from: brand});

        const currentClaimable = await agreement.claimable();
        assert.equal(currentClaimable.toString(10), parseInt(agreementPrevClaimable.toString(10))+reward);
    });
    it('should lock deliverable', async () => {
        await agreement.lock({from: brand});
        assert.equal( await agreement.locked(), true);
    })
});
