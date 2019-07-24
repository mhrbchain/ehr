const Ehr = artifacts.require('ElectronicHealthSystem');

contract('ElectronicHealthSystem', (accounts) => { //accounts gets all the accounts availabe in the ganache blockchain
    before(async() => {
        this.ehr = await Ehr.deployed(); // await are used as usually in dapps the flow is asynchronous
    })

    it('deploys successfully', async () => {
        const address = await this.ehr.address;
        assert.notEqual(address, 0x0);
        assert.notEqual(address, '');
        assert.notEqual(address, null);
        assert.notEqual(address, undefined);
    })
})