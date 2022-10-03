@isTest
public with sharing class StatementAccountControllerTest {
    private static List<HexaBPM__Service_Request__c> createdSRList; 
    public static testmethod void TestStatementAccountController(){
        
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE name ='FSRA'];
        Operating_Unit__c ou = new Operating_Unit__c(Oracle_Site_Id__c = '103', Source_System__c='FSRA', Business_Hour__c = bHours.Id,
                                                     Operating_Unit_Name__c = 'Financial Services Regulatory Authority OU', Entity_Code__c = '02');
        insert ou;
        
        DateTime dt = Datetime.now();
        String curYear = String.ValueOf(Date.Today().Year());
        GL_Period_Configuration__c gp1 = new GL_Period_Configuration__c(Active__c=true, Month__c =dt.format('MMMM'), Year__c=curYear);
        insert gp1;
        
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '123';
        newAccounts[0].Source_System_Name__c = 'FSRA';
        newAccounts[0].Oracle_site_id__c = '103';
        insert newAccounts; 
                    
        List<Contact> newContacts = TestClassUtility.createContacts(1, newAccounts[0].Id);
        newContacts[0].Portal_User_Creation__c = true;
        
        newContacts[0].Community_Username__c = 'test1@adgm.portal';
        insert newContacts;  
        
        createdSRList = TestUtility.createSR(1,'Initial_Approval');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].HexaBPM__Contact__c = newContacts[0].Id;
        insert createdSRList;
        
        Receipt__c recp = new Receipt__c();
        recp.Status__c='Success';
        //recp.Receipt_Created_Date__c = Datetime.now().format('yyyy-MM-dd');
        recp.Service_Request__c = createdSRList[0].Id;
        recp.Entity__c = newAccounts[0].Id;
        recp.Status__c = 'Success';
        recp.Payment_Method__c = 'Credit Card'; 
        recp.Amount__c = 20;
        insert recp;
        /*Id cmRecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Credit Memo' LIMIT 1].Id;
        List<Invoice__c> listInvoice = TestClassUtility.createInvoice(1,newAccounts);
        listInvoice[0].Invoice_Balance__c = 100;
        listInvoice[0].Payment_Currency__c = 'AED';
        listInvoice[0].RecordTypeId = cmRecordTypeId;//Schema.SObjectType.Invoice__c.getRecordTypeInfosByDeveloperName().get('Credit_Memo').getRecordTypeId();
        listInvoice[0].GL_Date__c = Date.today();
        listInvoice[0].Oracle_Invoice_Id__c = '12345432';
        insert listInvoice;
        listInvoice[0].Status__c='Approved' ; 
        
        listInvoice[0].Generate_Document__c = true;
        listInvoice[0].Document_Version__c = 0;
        update listInvoice;*/
        
        HexaBPM__SR_Price_Item__c objPriceItem = new HexaBPM__SR_Price_Item__c();
           objPriceItem.HexaBPM__ServiceRequest__c = createdSRList[0].Id;
           objPriceItem.Entity__c  = newAccounts[0].Id;
           //objPriceItem.HexaBPM__Product__c = objPOBoxProduct[0].Id;
           objPriceItem.HexaBPM__Price__c = 89;
           //objPriceItem.Markup_Amount__c = ;
           objPriceItem.HexaBPM__Status__c = 'Blocked';
           objPriceItem.HexaBPM__Sys_Added_through_Code__c = true;
           objPriceItem.HexaBPM__Non_Reevaluate__c = true;
            insert objPriceItem;
        
        //List<HexaBPM__SR_Price_Item__c> srPriceList = [SELECT Id, CreatedDate, HexaBPM__Status__c FROM HexaBPM__SR_Price_Item__c WHERE Id = :objPriceItem.Id];
        
        List<Receipt__c> receList = [SELECT Id, CreatedDate, Receipt_Created_Date__c FROM Receipt__c WHERE Id = :recp.Id];
        system.debug('@@LIST '+receList[0]);
        User portalUser = [SELECT Id FROM User WHERE ContactId = :newContacts[0].Id];
        
        Test.startTest();
        system.runAs(portalUser){
            String strStart = Datetime.now().addDays(-5).format('yyyy-MM-dd');
            String strEnd = Datetime.now().addDays(10).format('yyyy-MM-dd');
            
            system.currentPageReference().getParameters().put('fromDate',strStart);
            system.currentPageReference().getParameters().put('toDate',strEnd);
            StatementAccountController prc = new StatementAccountController();
            prc.fetchStatementAccount();
            
        } 
        Test.stopTest();
 
    }
    
}