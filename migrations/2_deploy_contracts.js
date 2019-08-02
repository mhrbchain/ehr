var EHR = artifacts.require("ElectronicHealthSystem");
var Patient = artifacts.require("Patient");
var Provider = artifacts.require("Provider");

module.exports = function(deployer) {
    deployer.deploy(EHR);
    deployer.deploy(Provider, "0x9ffF32165225148F1D583225Ee6250b185FE4808");
    deployer.deploy(Patient, "0x9ffF32165225148F1D583225Ee6250b185FE4808");
}