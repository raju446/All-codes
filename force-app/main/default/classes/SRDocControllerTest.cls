@isTest
public with sharing class SRDocControllerTest {
  
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    
    public static testmethod void TestSRDocController(){
    
        HexaBPM__Document_Master__c docMaster = new HexaBPM__Document_Master__c();
        docMaster.HexaBPM__Code__c = 'GENERAL';
        docMaster.HexaBPM__Available_to_client__c = true;
        insert docMaster;
    
        HexaBPM__SR_Steps__c srStep = new HexaBPM__SR_Steps__c();
        insert srStep;
        
        HexaBPM__SR_Template_Docs__c srtempDoc = new HexaBPM__SR_Template_Docs__c();
        srtempDoc.Available_to_Community_on_Step__c = srStep.Id;
        srtempDoc.HexaBPM__Document_Master__c = docMaster.Id;
        insert srtempDoc;

        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        insert newAccounts; 
        
        List<SR_Doc_Running_Number__c> srDocRunNumList = TestClassUtility.createSRDocRunningNumber();
        insert srDocRunNumList;

        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;

        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  

        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];


        system.runAs(portalUser){

            createdSRList = TestUtility.createSR(1,'Initial_Approval');
            createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id; 
            insert createdSRList;

            HexaBPM__SR_Doc__c srDoc = new HexaBPM__SR_Doc__c();
            srDoc.HexaBPM__Service_Request__c = createdSRList[0].Id;
            srDoc.HexaBPM__Document_Master__c = docMaster.Id;
            srDoc.HexaBPM__SR_Template_Doc__c = srtempDoc.Id;
            insert srDoc;
            
            HexaBPM__Step__c step = new HexaBPM__Step__c();
            step.HexaBPM__SR__c = createdSRList[0].Id;
            step.HexaBPM__SR_Step__c = srStep.Id;
            insert step;
            
            List<HexaBPM__Step__c> stepList = [Select Id from HexaBPM__Step__c];
                                                    
            system.debug('$$LIST: '+stepList);

            system.currentPageReference().getParameters().put('id', createdSRList[0].Id);

            SRDocController src = new SRDocController();
        } 

    }
    
}