const Manufacturer = artifacts.require("manufacturer");

contract("manufacturer", (accounts) => {
    it("should create a new product batch and return it", async () => {
        const manufacturerInstance = await Manufacturer.deployed();
        let productId = "productId-1"
        let batchCode = "batch1"
        const tx = await manufacturerInstance.loadNewBatch(productId, batchCode);
        const batchFromContract = await manufacturerInstance.viewBatchData(batchCode);
        assert.equal(batchFromContract.productId, productId, "El ID recibido es distinto al enviado");
    });

    it("should fail if searching for an inexistent batch", async () => {
        const manufacturerInstance = await Manufacturer.deployed();
        const inexistentBatchCode = "doesntexist";
        try {
            const tx = await manufacturerInstance.viewBatchData(inexistentBatchCode);
        } catch (error) {
            assert.include(error.message, "revert", "El mensaje de error debería contener revert")
        }
    })
})