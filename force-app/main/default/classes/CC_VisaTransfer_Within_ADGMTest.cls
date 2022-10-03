/*****************************************
Author : Azmath
******************************************/
@isTest
public class CC_VisaTransfer_Within_ADGMTest
{
     
    static testMethod void CC_VisaTransfer_Within_ADGM_UT()
    {
        List<HexaBPM__Service_Request__c> createdSRList; 
        List<HexaBPM__Step__c> createdstepList;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts;
        
        /*List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Unified_ID_No__c = '1234';
        newContacts[0].Employment_Status__c = 'Active';
        insert newContacts;*/
        
        List<Account> newAccounts1 = TestClassUtility.createAccounts(1);
        insert newAccounts1;
        
        List<Contact> newContacts1 = TestClassUtility.createContacts(1, newAccounts1[0].Id);
        newContacts1[0].Unified_ID_No__c = '1234';
        newContacts1[0].Employment_Status__c = 'Active';
        insert newContacts1;
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
        createdSRList[0].HexaBPM__Contact__c = newContacts1[0].Id;
        createdSRList[0].Previous_Visa_Number__c = '1234';
        createdSRList[0].Free_Zone_Transferring_From__c= 'ADGM';
        createdSRList[0].Previous_Visa_Number__c= '1234';
        createdSRList[0].Unified_ID_No__c= '1234';
        insert createdSRList;
        
        createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,null);
        insert createdstepList;
        
        Document_Details__c docs = new Document_Details__c();  
        docs.Document_Status__c='Active';
        docs.Document_Type__c= 'Residence Visa';
        docs.Account__c = newAccounts1[0].Id;
        docs.Document_Cancel_Date__c = system.today();
        docs.Contact__c = newContacts1[0].Id;
        //docs.Service_Request__c = createdSRList[0].Id;
        insert docs;
        
        Test.startTest();
        
            Contact_SR_Field_Mapping__c mapping = new Contact_SR_Field_Mapping__c(Name='AccountId',Active__c=true,Contact_Field_API_Name__c='AccountId',SR_Field_API_Name__c='HexaBPM__Customer__c');
            insert mapping;
            
            HexaBPM__Step__c step = [Select HexaBPM__SR__r.Previous_Visa_Number__c,HexaBPM__SR__r.HexaBPM__Customer__c,HexaBPM__SR__r.HexaBPM__Record_Type_Name__c ,
                            HexaBPM__SR__r.Health_Insurance_Provider__c,HexaBPM__SR__r.Free_Zone_Transferring_From__c,HexaBPM__SR__r.Unified_ID_No__c
                                     FROM HexaBPM__Step__c WHERE ID=:createdstepList[0].id];
            Document_Detail_SR_Field_Mapping__c dmap = new Document_Detail_SR_Field_Mapping__c(Name='1',Active__c=true,Service_Request_Recordtype_API__c=step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c,
                                                        Document_Type__c='Residence Visa',SR_Field_API_Name__c='Health_Insurance_Provider__c',
                                                        Document_Detail_Field_API_Name__c='Health_Insurance_Provider__c');
            insert dmap;
            
            CC_VisaTransfer_Within_ADGM con = new CC_VisaTransfer_Within_ADGM();
            con.EvaluateCustomCode(createdSRList[0],step);
            
        Test.stopTest();
    }

}