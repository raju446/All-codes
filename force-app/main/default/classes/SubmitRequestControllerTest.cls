@isTest
private class SubmitRequestControllerTest{

    public static list<HexaBPM__SR_Status__c> lstSRStatus = new list<HexaBPM__SR_Status__c>();

    public static void init(){
        lstSRStatus = new list<HexaBPM__SR_Status__c>();
        HexaBPM__SR_Status__c objSRStatus;
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Closed';
        objSRStatus.HexaBPM__Code__c = 'CLOSED';
        objSRStatus.HexaBPM__Type__c = 'End';
        lstSRStatus.add(objSRStatus);
        
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Awaiting Sanction Approval';
        objSRStatus.HexaBPM__Code__c = 'AWAITING_SANCTION_APPROVAL';
        objSRStatus.HexaBPM__Type__c = 'Start';
        lstSRStatus.add(objSRStatus);

        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Rejected';
        objSRStatus.HexaBPM__Code__c = 'REJECTED';
        objSRStatus.HexaBPM__Type__c = 'Rejected';
        lstSRStatus.add(objSRStatus);
        
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Awaiting Approval';
        objSRStatus.HexaBPM__Code__c = 'AWAITING_APPROVAL';
        objSRStatus.HexaBPM__Type__c = 'Start';
        lstSRStatus.add(objSRStatus);
        
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Approved';
        objSRStatus.HexaBPM__Code__c = 'APPROVED';
        objSRStatus.HexaBPM__Type__c = 'Intermediate';
        lstSRStatus.add(objSRStatus);
        
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Submitted';
        objSRStatus.HexaBPM__Code__c = 'SUBMITTED';
        lstSRStatus.add(objSRStatus);
        
        objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Draft';
        objSRStatus.HexaBPM__Code__c = 'DRAFT';
        lstSRStatus.add(objSRStatus);
        
        insert lstSRStatus;
    }

    static testMethod void submitRequestTestPoBoxSR(){
    
        init();
    
        Product2 objProd = new Product2();
        objProd.productcode = 'P_O_BOX_FEES';
        objProd.Name = 'PO Box Fees';
        insert objProd;
    
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'P_O_Box_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[6].Id; // changing the status to Draft
        createdSRList[0].HexaBPM__External_SR_Status__c = lstSRStatus[6].Id; // changing the status to Draft
        insert createdSRList;
        
        test.startTest();
            system.runAs(portalUser){
                system.currentPageReference().getParameters().put('Id', createdSRList[0].Id);
                SubmitRequestController subReqCtrlr = new SubmitRequestController();
                subReqCtrlr.CheckPriceLines();
                subReqCtrlr.SubmitSR();
                subReqCtrlr.BacktoSR();
            }
        test.stopTest();
    }
    
    static testMethod void submitRequestTestDependentVisaNewSR(){
        init();
    
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';        
        insert newAccounts; 
        
        List<Recordtype> employeeRectypeId = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = 'Contact_Employee' LIMIT 1];
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        
        newContacts[1].FirstName = 'Employee FirstName';
        newContacts[1].LastName = 'Employee Last';
        newContacts[1].RecordtypeId = employeeRectypeId[0].Id;
        newContacts[1].Gross_Monthly_Salary__c = 20000;
        newContacts[1].Employment_Status__c = 'Active';
        newContacts[1].UAE_Residence_Visa_Expiry_Date__c = System.Today().addYears(1);
        newContacts[1].Passport_No__c = 'PASS-8326418735';
        newContacts[1].Passport_Expiry_Date__c = System.Today().addYears(3);
        newContacts[1].Work_Permit_Expiry_Date__c = System.Today().addYears(1);
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Dependent_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[1].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[6].Id; // changing the status to Draft
        createdSRList[0].HexaBPM__External_SR_Status__c = lstSRStatus[6].Id; // changing the status to Draft
        createdSRList[0].Sponsor_Gender__c = 'Male';
        createdSRList[0].Relationship_with_Sponsor__c = 'Father';
        createdSRList[0].Sponsor_Passport_No__c = 'PASS-8326418735';
        insert createdSRList;
        
        test.startTest();
            system.runAs(portalUser){
                system.currentPageReference().getParameters().put('Id', createdSRList[0].Id);
                SubmitRequestController subReqCtrlr = new SubmitRequestController();
                subReqCtrlr.CheckPriceLines();
                subReqCtrlr.SubmitSR();
            }
        test.stopTest();
    }
    
    static testMethod void submitRequestTestDependentVisaNewSR2(){
        init();
    
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        insert newAccounts; 
        
        List<Recordtype> employeeRectypeId = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = 'Contact_Employee' LIMIT 1];
        List<Contact> newContacts = TestClassUtility.createContacts(2, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        
        
        newContacts[1].FirstName = 'Employee FirstName';
        newContacts[1].LastName = 'Employee Last';
        newContacts[1].RecordtypeId = employeeRectypeId[0].Id;
        newContacts[1].Gross_Monthly_Salary__c = 20000;
        newContacts[1].Employment_Status__c = 'Active';
        newContacts[1].UAE_Residence_Visa_Expiry_Date__c = System.Today().addYears(1);
        newContacts[1].Passport_No__c = 'PASS-8326418735';
        newContacts[1].Passport_Expiry_Date__c = System.Today().addYears(3);
        newContacts[1].Work_Permit_Expiry_Date__c = System.Today().addYears(1);
        insert newContacts;  
        
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Dependent_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[1].Id;
        createdSRList[0].HexaBPM__Internal_SR_Status__c = lstSRStatus[6].Id; // changing the status to Draft
        createdSRList[0].HexaBPM__External_SR_Status__c = lstSRStatus[6].Id; // changing the status to Draft
        createdSRList[0].Sponsor_Gender__c = 'Female';
        createdSRList[0].Sponsor_Passport_No__c = 'PASS-8326418735';
        createdSRList[0].Relationship_with_Sponsor__c = 'Father';
        insert createdSRList;
        
        test.startTest();
            system.runAs(portalUser){
                system.currentPageReference().getParameters().put('Id', createdSRList[0].Id);
                SubmitRequestController subReqCtrlr = new SubmitRequestController();
                subReqCtrlr.CheckPriceLines();
                subReqCtrlr.SubmitSR();
                
                Receipt__c rcpt= new Receipt__C();
                rcpt.Entity__c=createdSRList[0].HexaBPM__Customer__c;
                rcpt.Oracle_Receipt_Id__c=null;
                rcpt.Amount__c=100;
                rcpt.Payment_Currency__c = 'AED';
                rcpt.Status__c='Success';
                rcpt.Payment_method__c='Approved';
                insert rcpt;
                decimal ReceiptsAmount = ApexCodeUtility.getOpenReceiptsAmount(createdSRList[0].HexaBPM__Customer__c);
                system.debug('test ReceiptsAmount'+ReceiptsAmount);
                subReqCtrlr.CheckPriceLines();
                subReqCtrlr.SubmitSR();
               
                // cover negative scenarios 
                createdSRList[0].HexaBPM__External_SR_Status__c =lstSRStatus[4].Id; // Approved
                subReqCtrlr.SubmitSR();
                subReqCtrlr.BacktoSR();
            }
        test.stopTest();
    }
    
    
}