const Facultad = artifacts.require("Facultad");
module.exports = function(deployer) {
  deployer.deploy(Facultad,1000);
};
