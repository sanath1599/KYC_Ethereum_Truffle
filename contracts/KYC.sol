//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract KYC{

    address adminAddress;
    constructor(){
        adminAddress = msg.sender;
    }

    

	// Customer Struct. COntaints the Customer Definition
	struct Customer {
		string customerName;                                                                                // The username is Provided by the Customer and is used to track the customer details.
		bytes32 customerData;                                                                               // This is the hash of the data or identity documents provided by the Customer.
		bool customerKycStatus;                                                                             // This is the rating given to the customer by other banks.
		uint256 upvotesCustomer;                                                                            // This is the number of upvotes received from other banks over the Customer data.
		uint256 downvotesCustomer;																			// This is the number of upvotes received from other banks over the Customer data. 
		address bankAddress;                                                                                     // If customer wants to share data then true.
	}

	// Bank Struct. COntaints the Bank Definition
	struct Bank {
		string bankName;                                                                                   // This variable specifies the name of the bank/organisation.
		address ethAddress;                                                                                 
		uint256 bankReport;                                                                                 // This is the rating received from other banks or admin based on number of valid/invalid KYC verifications.
		uint256 kycCount;                                                                                   // These are the number of KYC requests initiated by the bank.
		bool kycPermission ;                                                                                // This is a boolean to hold status of bank. If set to false bank cannot upvote/downvote any more customers.
		bytes32 bankRegNumber; 																				// This is the registration number for the bank. This is unique.
		address bankAddress;
		bool isBank;

	}

	// KYC_Request Struct.COntaints the Kyc Definition
	struct KYC_Request {
		string customerName;                                                                                // The username is Provided by the Customer and is used to track the customer details.
		address bankAddress;                                                                                // This is a unique address of the bank that initiated the KYC request.
		bytes32 customerData;                                                                               // This is the hash of the data or identity documents provided by the Customer.
	    bool shareData;                                                                                     // If customer wants to share data then true.
	}

	// State Variables of Smart Contract //
	mapping(string => Customer) public customersList;                                                       // The main Customer state variable of the type 'mapping'. This will be like a hash-map of all customers.
	mapping(address => Bank) public banksList;                                                               // The main Bank state variable of the type 'mapping'. This will be like a hash-map of all banks.
	mapping(address => KYC_Request) public kycList;                                                          // The main KYC_Requests state variable of the type 'mapping'. This will be like a hash-map of all KYC_Requests.

	//*** Events of this Smart Contract ***//

	event AddRequest (string customerName, bytes32 customerData);                                           // To add the KYC request to the requests list.
	event RemoveRequest (string customerName,bytes32 customerHashData, address bankAddress);                // To remove the requests from the requests list.
	event AddCustomer (string customerName, bytes32 customerData);                                          // To add a customer to the customer list.
	event RemoveCustomer (string customerName, address bankAddress);                                        // To remove the customer from the customer list.
	event UpvoteCustomer (string customerName, address bankAddress);                                        // To allow a bank to upvote a customer.
	event DownvoteCustomer (string customerName, address bankAddress);										// To allow a bank to downvote a customer.
	event ModifyCustomerData (string customerName, address bankAddress);                                    // To allow a bank to modify a customer's data. Only applicable for validated customers present in the customer list.
    event AddBank (string bankName);                                                                        // To add a new bank in the network. Only by admin.
    event RemoveBank (address bankAddress);                                                                 // To remove a bank from the network. Only by admin.


  //*** Bank Interface Methods***//
 

	// This function will add the KYC request to the requests list.
	function addRequest(string memory customerName, bytes32 customerData) external returns(string memory) {
		kycList[msg.sender].customerName = customerName;
		kycList[msg.sender].customerData = customerData;
// 		kycList[msg.sender].bankAddress = msg.sender;
		emit AddRequest(customerName, customerData);
		return "Request added";
	}

	// This function is used to add a customer to the customer list.
	function addCustomer(string memory newCustomerName, bytes32 newCustomerData) external returns(string memory) {
	    if (banksList[msg.sender].kycPermission  == true) {
	    customersList[newCustomerName].customerName = newCustomerName;
	    customersList[newCustomerName].customerData = newCustomerData;
	    customersList[newCustomerName].customerKycStatus = false;
		emit AddCustomer(newCustomerName, newCustomerData);
		customersList[newCustomerName].upvotesCustomer = 0;
		customersList[newCustomerName].downvotesCustomer = 0;
		return "Customer Data Stored";
		}else {
			return "Not Allowed, KycPermission = False";
		}
	}

    // This function is used to remove the requests from the requests list.
    function removeRequest(string memory customerName, bytes32 customerHashData) external {
        delete kycList[msg.sender];
        emit RemoveRequest(customerName,customerHashData, msg.sender);
       
	}

	// This function is used to remove the customer from the customer list.
	function removeCustomer(string memory customerName) external returns(uint256) {
		delete customersList[customerName];
		emit RemoveCustomer(customerName, msg.sender);
		return 1;
	}

	// This function will allow a bank to view the details of a customer.
	function viewCustomer(string memory customerName) public view returns(string memory, bytes32) {
		 bytes32 a = customersList[customerName].customerData;
		 string memory b = customersList[customerName].customerName;
		 return(b,a);
	}

    // This function will allow a bank to upvote a customer.
	function upvoteCustomer(string memory customerName) external{
		customersList[customerName].upvotesCustomer += 1;
		 if(customersList[customerName].upvotesCustomer >= 2){
	        customersList[customerName].customerKycStatus = true;
	    }
		emit UpvoteCustomer(customerName, msg.sender);
	}
	
	// This function will allow a bank to downvote a customer.
	function downvoteCustomer(string memory customerName) external{
		customersList[customerName].downvotesCustomer -= 1;
		emit DownvoteCustomer(customerName, msg.sender);
	}

	// This function will allow a bank to modify a customer's data.
	function modifyCustomer(string memory customerName, bytes32 customerHashData) external returns(uint256) {
		if (banksList[msg.sender].kycPermission  == true) {
		    customersList[customerName].customerName = customerName;
		    customersList[customerName].customerData = customerHashData;
		    customersList[customerName].bankAddress = msg.sender;
		    emit ModifyCustomerData(customerName, msg.sender);
		    emit RemoveRequest(customerName,customerHashData, msg.sender);
			customersList[customerName].upvotesCustomer = 0;
			customersList[customerName].downvotesCustomer = 0;
		    return 1;
		} else return 0;
	}
	

  
   //This function will check if Bank is present in the mapping
   function isBank(address bankAddress) public view returns(bool) {
         return banksList[bankAddress].isBank;
      
  }

    
	// This function will fetch customer rating from the smart contract.
	function getCustomerStatus(string memory customerName) public view returns(bool) {
		return customersList[customerName].customerKycStatus;
	}

	// This function will fetch respective Bank's Report from the smart contract.
	function getBankReport(address bankAddress) public view returns(uint256) {
		return banksList[bankAddress].bankReport;
	}

   // This function will fetch the bank details.
  function viewBankDetails(address bankAddress) public view returns(Bank memory){  
      
      Bank memory b = banksList[bankAddress];
      return (b);                                                 
  }


  //*** Admin Interface Methods***//
  
  //This modifier will restrict use of admin functionalities
  modifier onlyAdmin {
      require(msg.sender == adminAddress, "Access Denied-Admin Only");
      _;
   }
  

	// This function allows the admin to add a bank to the KYC Contract. 
	function addBank(string memory newBankName, address newBankAddress, bytes32 newbankRegNumber) external onlyAdmin{
	        banksList[newBankAddress].bankName = newBankName;
	        banksList[newBankAddress].bankAddress = newBankAddress;
	        banksList[newBankAddress].bankRegNumber = newbankRegNumber;
	        banksList[newBankAddress].kycPermission  = true;
	        banksList[newBankAddress].bankReport = 0;
	        emit AddBank(newBankName);
	}
	
	
	// This method allows the admin to change the status of kycPermission of any of the banks.
	function modifyKycPermission(address bankAddress, bool permission) external onlyAdmin{
	      banksList[bankAddress].kycPermission  = permission;
	}
	

	// This method allows the admin to remove a bank from the KYC Contract.  
	function removeBank(address bankAddress) external returns(string memory){
	        delete banksList[bankAddress];
	        emit RemoveBank (bankAddress);
	}

}
