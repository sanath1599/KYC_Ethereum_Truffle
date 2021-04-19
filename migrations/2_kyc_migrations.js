var KYCContract = artifacts.require("kyc");

module.exports = function(deployer) {
  deployer.deploy(KYCContract);
};