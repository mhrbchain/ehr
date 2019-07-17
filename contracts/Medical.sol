//pragma solidity ^0.4.22;
pragma solidity ^0.5.0;

contract ElectronicHealthSystem{

  address[] public providers;

  uint public providerCount;

  mapping (address => address) public profiles;
  mapping (address => bool) profileExists;

  function registerAsPatient(string memory _fName, string memory _lName, string memory _dateOfBirth, string memory _addressResidence) public {
    require(!profileExists[msg.sender],'Patient already exists');
    address newPatient = address(new Patient(_fName, _lName, _dateOfBirth, _addressResidence, msg.sender));
    profiles[msg.sender] = newPatient;
    profileExists[msg.sender] = true;
  }

  function registerAsProvider() public {
    require(!profileExists[msg.sender], 'Provider already exists');
    address newProvider = address(new Provider(msg.sender));
    providers.push(newProvider);
    profiles[msg.sender] = newProvider;
    profileExists[msg.sender] = true;
    providerCount++;
  }
}

contract Provider {

    mapping (address => bool) patients;

    address[] public patientAddresses;

    address[] public requests;

    mapping (address=>bool) public sentRequests;

    uint public numberOfPatients;

    address public owner;

    modifier ownerOnly{
      require(msg.sender == owner,'Permission Denied');
      _;
    }

    constructor(address _owner) public {
      owner = _owner;
    }

    function addPatient(address _patientAddress) public ownerOnly {
      require(!sentRequests[_patientAddress],'Patient already added');
      Patient patient = Patient(_patientAddress);
      patient._providerRequests(address(this));
      sentRequests[_patientAddress] = true;
    }

    function acceptPatient(uint _index) public ownerOnly {
      Patient patient = Patient(requests[_index]);
      patientAddresses.push(requests[_index]);
      //deleteRequest(_index);
      numberOfPatients++;
      delete requests[_index];
      patient._clearRequest(address(this));
    }

    function pendingRequests() public ownerOnly view returns (address[] memory) {
      return requests;
    }

    function deleteRequest(uint _index) public ownerOnly {
        if (_index > requests.length) return;
        for(uint i = _index ; i < requests.length; i++){
            requests[i] = requests[i+1];
        }
        requests.length--;
    }

    function patientList() public ownerOnly view returns (address[] memory) {
      return patientAddresses;
    }

    function _clearRequest(address _patientAddress) public {
      sentRequests[_patientAddress] = false;
      patientAddresses.push(_patientAddress);
      numberOfPatients++;
    }

    //Allow providers to send a request
    function _patientRequest(address _patientAddress) public {
      requests.push(_patientAddress);
    }

    function uploadFiles(bytes memory _ipfsHash, address _patientAddress) public ownerOnly {
        Patient patient = Patient(_patientAddress);
        patient.uploadFiles(_ipfsHash);
    }

    function getFiles(uint _index, address _patientAddress) public ownerOnly view returns (bytes memory) {
        Patient patient = Patient(_patientAddress);
        bytes memory file = patient.getFiles(_index);
        return file;
    }
}

contract Patient{

    struct Identity {
        string firstName;
        string lastName;
        string dateOfBirth;
        string addressResidence;
    }

    Identity identity;

    address public owner;

    address[] public addedProviders;

    mapping (address => bool) public addedProvidersAccess;

    mapping (address => bool) public sentRequests;

    address[] public requests;

    bytes[] files;

    uint public numberOfMedicalProviders;

    modifier ownerOnly(){
        require(msg.sender == owner,'Access Denied');
        _;
    }

    modifier restricted(){
        require(msg.sender == owner || addedProvidersAccess[msg.sender],'Not enough Persmission');
        _;
    }

    constructor(string memory _fName, string memory _lName, string memory _dateOfBirth, string memory _addressResidence, address _owner) public {
        identity.firstName = _fName;
        identity.lastName = _lName;
        identity.dateOfBirth = _dateOfBirth;
        identity.addressResidence = _addressResidence;
        owner = _owner;
        numberOfMedicalProviders = 0;
    }

    function _clearRequest(address _providerAddress) public {
      sentRequests[_providerAddress] = false;
      addedProviders.push(_providerAddress);
      addedProvidersAccess[_providerAddress] = true;

    }

    function _providerRequests(address _providerAddress) public {
      requests.push(_providerAddress);
    }

    function getRequests() public ownerOnly view returns(address[] memory){
      return requests;
    }

    function addProvider(address _providerAddress)  public ownerOnly {
      require(!addedProvidersAccess[_providerAddress],'Permission Denied');
      Provider provider = Provider(_providerAddress);
      provider._patientRequest(address(this));
      sentRequests[_providerAddress] = true;
      numberOfMedicalProviders++;
      addedProvidersAccess[_providerAddress] = true;
    }

    function acceptProvider(uint _index) public ownerOnly {
      Provider provider = Provider(requests[_index]);
      addedProviders.push(requests[_index]);
      numberOfMedicalProviders++;
      addedProvidersAccess[requests[_index]] = true;
      provider._clearRequest(address(this));
      delete requests[_index];
    }

    function deleteRequest(uint _index) public ownerOnly {
        if (_index > requests.length) return;
        for(uint i = _index ; i < requests.length; i++){
            requests[i] = requests[i+1];
        }
        requests.length--;
    }

    function uploadFiles(bytes memory ipfsHash) public restricted {
        files.push(ipfsHash);
    }

    function getFiles(uint _index) public restricted view returns (bytes memory) {
        return files[_index];
    }

    function returnIdentity() public ownerOnly view returns (string memory, string memory, string memory, string memory) {
        return (identity.firstName, identity.lastName, identity.dateOfBirth, identity.addressResidence);
    }
}
