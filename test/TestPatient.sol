pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Medical.sol";

contract TestPatient {
    //The address of the adoption contract to be tested
    Patient patient = Patient(DeployedAddresses.Patient());

    //The id of the pet that will be used for testing
    string expectedFName = "Patien1";
    string expectedLName = "Patient1";
    string expectedDob = "1989/04/04";
    string expectedAddr  ="Kathmandu";

    // Testing retrieval of a single pet's owner
    function testReturnIdentity() public {
        string memory fname = patient.returnIdentity();

        Assert.equal(fname, expectedFName, "Ids match");
    }
}