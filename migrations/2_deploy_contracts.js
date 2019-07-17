var EHR = artifacts.require("ElectronicHealthSystem");
var Patient = artifacts.require("Patient");
var Provider = artifacts.require("Provider");

module.exports = function(deployer) {
    deployer.deploy(EHR);
    deployer.deploy(Provider, "0x5b29eE65BC551b5388401BCa0d25280Bee001ee4");
    deployer.deploy(Patient, "Patien1", "Patient1", "1989/04/04", "Kathmandu", "0x5b29eE65BC551b5388401BCa0d25280Bee001ee4");
}