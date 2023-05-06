var Manufacturer = artifacts.require("manufacturer");
module.exports = function(deployer) {
    deployer.deploy(Manufacturer)
}