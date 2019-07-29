//pragma solidity ^0.4.22;
pragma solidity ^0.5.0;

contract ElectronicHealthSystem{

  address owner;
  address[] providers;
  address[] patients;

  mapping (address => address) public profileAddress;
  mapping (address => bool) profileExists;

  modifier ownerOnly {
    require(msg.sender == owner, 'Not the owner');
    _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function registerAsPatient() public returns (address){
    require(!profileExists[msg.sender],'Patient already exists');
    address newPatient = address(new Patient(msg.sender));
    profileAddress[msg.sender] = newPatient;
    profileExists[msg.sender] = true;
    return profileAddress[msg.sender];
  }

  function registerAsProvider() public returns (address) {
    require(!profileExists[msg.sender], 'Provider already exists');
    address newProvider = address(new Provider(msg.sender));
    providers.push(newProvider);
    profileAddress[msg.sender] = newProvider;
    profileExists[msg.sender] = true;
    return profileAddress[msg.sender];
  }
}

contract Provider {

    // mapping (address => bool) patients;

    // address[] public patientAddresses;
    address[] public addedPatients;
    address[] requests;

    mapping (address=>bool) public sentRequests;

    // uint public numberOfPatients;

    address owner;

    modifier ownerOnly{
      require(msg.sender == owner,'Permission Denied');
      _;
    }

    constructor(address _owner) public {
      owner = _owner;
    }

    function _addAddedPatients(address _patientAddress) public ownerOnly {
      Patient patient = Patient(_patientAddress);
      require(sentRequests[_patientAddress]!=true, 'Permission Denied');
      patient._providerRequests(address(this));
      sentRequests[_patientAddress] = true;
    }

    function _patientRequests(address _patientAddress) public {
      requests.push(_patientAddress);
    }

    function requestsForApproval() public ownerOnly view returns (address[] memory) {
      return requests;
    }

    function acceptPatient(uint _index) public ownerOnly {
      Patient patient = Patient(requests[_index]);
      addedPatients.push(requests[_index]);
      delete requests[_index];
      patient._addAddedProviders(address(this));
    }

    // function pendingRequests() public ownerOnly view returns (address[] memory) {
    //   return requests;
    // }

    // function deleteRequest(uint _index) public ownerOnly {
    //     if (_index > requests.length) return;
    //     for(uint i = _index ; i < requests.length; i++){
    //         requests[i] = requests[i+1];
    //     }
    //     requests.length--;
    // }

    // function patientList() public ownerOnly view returns (address[] memory) {
    //   return patientAddresses;
    // }

    // function _clearRequest(address _patientAddress) public {
    //   sentRequests[_patientAddress] = false;
    //   patientAddresses.push(_patientAddress);
    //   numberOfPatients++;
    // }

    // //Allow providers to send a request
    // function _patientRequest(address _patientAddress) public {
    //   requests.push(_patientAddress);
    // }

    // function uploadFiles(bytes memory _ipfsHash, address _patientAddress) public ownerOnly {
    //     Patient patient = Patient(_patientAddress);
    //     patient.uploadFiles(_ipfsHash);
    // }

    // function getFiles(uint _index, address _patientAddress) public ownerOnly view returns (bytes memory) {
    //     Patient patient = Patient(_patientAddress);
    //     bytes memory file = patient.getFiles(_index);
    //     return file;
    // }
}

contract Patient{

    // struct Identity {
    //     string firstName;
    //     string lastName;
    //     string dateOfBirth;
    //     string addressResidence;
    // }

    // Identity identity;

    // address public owner;

    address[] public addedProviders;

    // mapping (address => bool) public addedProvidersAccess;

    mapping (address => bool) public sentRequests;

    address[] public requests;

    address owner;

    bytes[] patientFiles;

    modifier ownerOnly {
      require(msg.sender == owner, 'Not the owner!');
      _;
    }

    // uint public numberOfMedicalProviders;

    // modifier ownerOnly(){
    //     require(msg.sender == owner,'Access Denied');
    //     _;
    // }

    // modifier restricted(){
    //     require(msg.sender == owner || addedProvidersAccess[msg.sender],'Not enough Persmission');
    //     _;
    // }

    constructor(address _owner) public {
        owner = _owner;
    }

    function _addAddedProviders(address _providerAddress) public {
      sentRequests[_providerAddress] = false;
      addedProviders.push(_providerAddress);
    }

    // function _clearRequest(address _providerAddress) public {
    //   sentRequests[_providerAddress] = false;
    //   addedProviders.push(_providerAddress);
    //   addedProvidersAccess[_providerAddress] = true;

    // }

    function _providerRequests(address _providerAddress) public {
      requests.push(_providerAddress);
    }

    // function getRequests() public view returns(address[] memory){
    //   return requests;
    // }
    function seeRequests() public view returns (address[] memory ) {
      return requests;
    }

    function addProvider(address _providerAddress)  public ownerOnly{
      // require(!addedProvidersAccess[_providerAddress],'Permission Denied');
      Provider provider = Provider(_providerAddress);
      require(sentRequests[_providerAddress]!=true, 'Permission Denied');
      provider._patientRequests(address(this));
      sentRequests[_providerAddress] = true;
      // numberOfMedicalProviders++;
      // addedProvidersAccess[_providerAddress] = true;
      requests.push(_providerAddress);
    }

    function requestsForApproval() public ownerOnly view returns (address[] memory) {
      return requests;
    }

    function acceptProvider(uint _index) public ownerOnly {
      Provider provider = Provider(requests[_index]);
      addedProviders.push(requests[_index]);
      // numberOfMedicalProviders++;
      // addedProvidersAccess[requests[_index]] = true;
      // provider._clearRequest(address(this));
      // delete requests[_index];
      delete requests[_index];
      provider._addAddedPatients(address(this));
    }

    function deleteRequest(uint _index) public {
        if (_index > requests.length) return;
        for(uint i = _index ; i < requests.length; i++){
            requests[i] = requests[i+1];
        }
        requests.length--;
    }

    function uploadFiles(bytes memory _hash) public ownerOnly {
        patientFiles.push(_hash);
    }

    function retrieveFile(bytes memory _hash) public view ownerOnly returns (bytes memory) {
        return _hash;
    }

    // function returnIdentity() public view returns (string memory) {
    //     return identity.firstName;
    // }
}
