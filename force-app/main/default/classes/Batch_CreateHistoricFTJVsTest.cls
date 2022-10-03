@isTest
public class Batch_CreateHistoricFTJVsTest {
	
    @isTest static void runTest1(){
        Journal_Header_Running_Number__c setting = new Journal_Header_Running_Number__c();
        setting.Name = 'Next Running Number';
        setting.Running_Number__c = 001;
        insert setting;
        
         GL_Combination_Setting__c gls3 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11221',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Unapplied',
                                                                       Lookup_Code__c = 'UNAPPLIED RECEIPTS',
                                                                       Lookup_Code_Meaning__c = 'Unapplied Receipts',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        INSERT gls3;
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE name ='FSRA'];
        Operating_Unit__c ou = new Operating_Unit__c(Oracle_Site_Id__c = '103', Source_System__c='FSRA', Business_Hour__c = bHours.Id,
                                                     Operating_Unit_Name__c = 'Financial Services Regulatory Authority OU', Entity_Code__c = '02');
        insert ou;
        
        DateTime dt = Datetime.now();
        String curYear = String.ValueOf(Date.Today().Year());
        GL_Period_Configuration__c gp1 = new GL_Period_Configuration__c(Active__c=true, Month__c =dt.format('MMMM'), Year__c=curYear);
        insert gp1;
        
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        acc[0].Oracle_site_id__c = '103';
        insert acc;
        
        List<Receipt__c> receipts = TestClassUtility.createReceipt(2, acc);
        receipts[0].Gl_date__c = date.today();
        receipts[0].Payment_Method__c = 'Credit Card';
        receipts[0].Transaction_Reference__c = 'TRTEST123';
        receipts[0].Oracle_Receipt_Id__c = '12343213';
        receipts[1].Gl_date__c = date.today();
        receipts[1].Payment_Method__c = 'Electronic Funds Transfer';
        receipts[1].Transaction_Reference__c = 'TRTEST1234';
        receipts[1].Status__c = 'Success';
        receipts[1].Oracle_Receipt_Id__c = '22343213';
        insert receipts;
        
        List<Fund_Transfer__c> fts = TestClassUtility.createFundTransfer(1,acc,acc);
        fts[0].Reference_Receipt__c = receipts[0].Id;
        fts[0].to_receipt__c = receipts[1].Id;
        fts[0].Status__c = 'Draft';
        insert fts;
        
        Test.startTest();
        
        	Database.executeBatch(new Batch_CreateHistoricFTJVs(),1);
        
        Test.stopTest();
        
    }
    
}