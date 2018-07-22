const Agreement = artifacts.require('./Agreement.sol');
const Token = artifacts.require('tokencontract/contracts/CCOIN.sol');
const abi = require('tokencontract').abi;

const moment = require('moment');
const testFixtures = require('./fixtures');
const Web3 = require('web3');

contract('AgreementTest', (accounts) => {
    const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:9545"));
    let agreement,
        expiration,        
        startTime, 
        brand;

    const image  = 'test image',   
        title = 'Credit Coin',   
        description = 'this is a description',
        client = 'Reebok',    
        budget = 600,    
        reach = '50,000 > 100,000',         
        numberOfPost = 3;
    before(async () => {
        brand = accounts[0];
        startTime = moment().unix().valueOf();
        expiration = moment().add(30, 'days').unix().valueOf();
        agreement = await Agreement.new(title, description, client, budget, 
            reach, image, expiration, startTime, numberOfPost, {from: brand});
    });

    it('should set correct initial values', async () => {
        assert.equal(parseInt(await agreement.expiration()), expiration);

        // CREATOR IS ADDED TO THE AGREEMENT
        const userID = 'The Creative One';
        const creator = web3.sha3(userID);
        await agreement.addCreator(creator);
        console.log(await agreement.getCreator(creator));
        assert.equal(await agreement.getCreator(creator), true);

        // CREATOR SUBMITS SOME CONTENT
        const contentArgs = [creator, "Running Shoes", "these shoes make you fast", 
        "gif", "123abc", "the-creative-123"];
        await agreement.submitContent(...contentArgs, {from: brand});

        // THIS IS HOW YOU RETRIEVE CONTENT
        const contentID = web3.sha3('123abc');
        const content = await agreement.getContentByID(contentID);
        assert.equal(await content[2], 'Running Shoes');

        // BRAND APPROVES CONTENT BASED ON CONTENT ID ( const contentID = web3.sha3('123abc'); )
        await agreement.approveContent(contentID);

        // NEW PAYOUT SHOULD HAVE BEEN GENERATED BECAUSE CONTENT WAS APPROVED
        const payout = await agreement.payouts(contentID);
        console.log(payout)
        assert.equal(await payout[0], contentID);
        assert.equal(await payout[1], 'the-creative-123');
        assert.equal(await payout[2], '123abc');
        assert.equal(await payout[3], false); // PAYOUT "isPayed" IS MARKED AS FALSE

        // PAYOUT WAS MADE IN BRAND PORTAL NOW MARK AGREEMENT PAYOUT "isPayed "AS TRUE
        await agreement.payout(contentID);
        const payoutAfterPaid = await agreement.payouts(contentID);
        console.log(payoutAfterPaid)
        assert.equal(await payoutAfterPaid[3], true);

        // EXAMPLE OF REQUESTRESUBMIT, and requestEdit
        await agreement.requestEdit(contentID);
        await agreement.requestResubmission(contentID);
        await agreement.disApproveContent(contentID);
    });

    // it('should add new content', async () => {
    //     await token.transfer(agreement.address, testFixtures.newContent[2], {from: brand});
    //     await agreement.addContent(...testFixtures.newContent, {from: brand});
    //     const content = await agreement.getContentByName(testFixtures.newContent[0])
    //     const balance = await agreement.currentBalance();
    //     assert.equal(content[0], testFixtures.newContent[0])
    //     assert.equal(content[1], testFixtures.newContent[1])
    //     assert.equal(content[2].toString(), 10+"")
    //     assert.equal(balance.toString(10), 10+"")
    // })

    // it('should fulfillDeliverable by creator', async () => {
    //     const id = web3.sha3(testFixtures.newContent[0])
    //     await agreement.fulfillDeliverable(id, {from: creator});
    //     const isFulfilled = await agreement.currentFulfillment(testFixtures.newContent[0], {from: creator});
    //     assert.equal(isFulfilled, true);
    // })

    // it('should approveDeliverable by brand', async () => {
    //     const id = web3.sha3(testFixtures.newContent[0])
    //     await agreement.approveDeliverable(id, {from: brand});
    //     const isFulfilled = await agreement.currentFulfillment(testFixtures.newContent[0], {from: brand});
    //     assert.equal(isFulfilled, true);
    // })

    // it('should complete deliverable update agreement balance and make reward claimable', async () => {
    //     const reward = 1000,
    //         name = "CompleteThis",
    //         description = "will Be Completed";
    //     const agreementPrevBal = await agreement.currentBalance();
    //     const agreementPrevClaimable = await agreement.claimable();

    //     await token.transfer(agreement.address, reward+parseInt(agreementPrevBal.toString(10)), {from: brand});
    //     await agreement.addContent(name, description, reward, {from: brand});

    //     const balance = await agreement.currentBalance();
    //     const expectedBalance = parseInt(agreementPrevBal.toString(10))+parseInt(reward.toString(10));
    //     assert.equal(balance.toString(10), expectedBalance.toString(10));

    //     const id = web3.sha3(name);
    //     await agreement.fulfillDeliverable(id, {from: creator});
    //     await agreement.approveDeliverable(id, {from: brand});

    //     const currentClaimable = await agreement.claimable();
    //     assert.equal(currentClaimable.toString(10), parseInt(agreementPrevClaimable.toString(10))+reward);
    // });
    // it('should lock deliverable', async () => {
    //     await agreement.lock({from: brand});
    //     assert.equal( await agreement.locked(), true);
    // })
});
