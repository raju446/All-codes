/*
    Author      :   Yogesh Mahajan 
    Class Name  :   EmployeeDetailController
    Description :   It is used as a controller for EmployeeDetails vf page
    Date        :   08/25/2019
*/
public class EmployeeDetailController {
    public String entityName {get;set;}
    public string licenseNumber {get;set;}
    public String profile_photo_png { get; set; }
    public String entityId;
    /*
    Name : EmployeeDetailController
    Description : Used to get url parameter
    */
    public EmployeeDetailController() {
        entityId = apexpages.currentpage().getparameters().get('id');
        string strOrgId = UserInfo.getOrganizationId();
		profile_photo_png = 'https://'+System.Label.Domain_Name+'.my.salesforce.com/servlet/servlet.ImageServer?id='+System.Label.ADGM_Logo_ID+'&oid=' + strOrgId ;
    }
    /*
    Name : getEmployeeDetails
    Description : Used to current employee details
    */
    public List<ExcelData> getEmployeeDetails() {
        List<ExcelData> listEmployeeData = new List<ExcelData>();
        ExcelData objExcelData;
        String queryString = '';
        List<String> empStatus = new List<String>{'Active', 'Cancelled'};
        try {
            list<User> lstUser = [Select contact.accountid,contact.Account.Name,contact.Account.Oracle_Party_Id__c, contact.account.Establishment_Card_No__c from User where id =: Userinfo.getUserid() limit 1];
            if(lstUser <> null && lstUser.size() > 0 && String.isNotBlank(lstUser[0].contactId)){
                entityName = lstUser[0].contact.Account.Name;
                licenseNumber = lstUser[0].contact.account.Establishment_Card_No__c;
            }
            
            queryString = 'SELECT Id, Name, FirstName, LastName, Email,Employee_Email_ID__c, Nationality_Arabic__c,Job_Title__c, Passport_No__c, Nationality__c , Employment_Status__c,Sponsor__r.Name, Employment_Type__c, Work_Permit_Expiry_Date__c, Account.Name, Account.Establishment_Card_No__c FROM Contact WHERE AccountId = :entityId AND Employment_Status__c <> null and Employment_Status__c IN:empStatus ORDER BY Employment_Status__c limit 3000';
            List<Contact> listContacts = Database.query(queryString);
            if(listContacts <> null && listContacts.size() > 0) {
                
                for(contact objContact : listContacts) {
                    objExcelData = new ExcelData();
                    
                    objExcelData.conFirstName = objContact.FirstName;
                    objExcelData.conLastName = objContact.LastName;
                    objExcelData.conEmpStatus = objContact.Employment_Status__c;
                    objExcelData.conEmail = objContact.Employee_Email_ID__c;
                    objExcelData.conJobTitle = objContact.Job_Title__c;
                    objExcelData.conPassportNumber = objContact.Passport_No__c;
                    objExcelData.conNationality = objContact.Nationality__c;
                    objExcelData.conSponsor = objContact.Sponsor__r.Name;
                    objExcelData.conEmpWPExpiry = objContact.Work_Permit_Expiry_Date__c;
                    
                    listEmployeeData.add(objExcelData);
                }
            }
            
           
        } catch(exception ex) {
            system.debug('Exception Is------->'+ex.getMessage());
        }
        
        return listEmployeeData;
    }
    
    /*
    Name : getTransferredEmployeeDetails
    Description : Used to Transferred employee details
    */
    public List<ExcelData> getTransferredEmployeeDetails() {
        List<ExcelData> listEmployeeData = new List<ExcelData>();
        ExcelData objExcelData;
        String queryString = '';
        try {
            queryString = 'SELECT Id, Name, Employee_Email_ID__c,Job_Title__c, Passport_Number__c,Residence_Visa_Number__c, Nationality__c, Work_Permit_Expiry_Date__c  FROM Transferred_Employees__c WHERE  Account__c = :entityId LIMIT 2000';
            List<Transferred_Employees__c> listTransferredEmployees = Database.query(queryString);
            if(listTransferredEmployees <> null && listTransferredEmployees.size() > 0) {
                for(Transferred_Employees__c objTransferredEmployees : listTransferredEmployees) {
                    objExcelData = new ExcelData();
                    objExcelData.conName = objTransferredEmployees.Name;
                    objExcelData.conEmpStatus = 'Transferred';
                    objExcelData.conEmpType = '';
                    objExcelData.conJobTitle = objTransferredEmployees.Job_Title__c;
                    objExcelData.conPassportNumber = objTransferredEmployees.Passport_Number__c;
                    objExcelData.conEmpWPExpiry = objTransferredEmployees.Work_Permit_Expiry_Date__c;
                    objExcelData.conEmail = objTransferredEmployees.Employee_Email_ID__c;
                    objExcelData.conResidenceVisaNumber = objTransferredEmployees.Residence_Visa_Number__c;
                    objExcelData.conNationality = objTransferredEmployees.Nationality__c;
                    listEmployeeData.add(objExcelData);
                }
            }
            
            
        } catch(exception ex) {
            system.debug('Exception Is------->'+ex.getMessage());
        }
        
        return listEmployeeData;
    }
    
    public class ExcelData {
        
        public String conFirstName {get;set;}
        public String conLastName {get;set;}
        public String conEmail {get;set;}
        public String conJobTitle {get;set;}
        public String conSponsor {get;set;}
        public String conPassportNumber {get;set;}
        public String conNationality {get;set;}
        public String conEmpStatus {get;set;}
        
        
        public String conName {get;set;}
        public String conResidenceVisaNumber {get;set;}
        public String conEmpType {get;set;}
        public Date conEmpWPExpiry {get;set;}
        
    }
}