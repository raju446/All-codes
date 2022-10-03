@isTest
public class Batch_CreateDecReceiptJVsTest {
    
    @isTest static void runTest(){
        Journal_Header_Running_Number__c setting = new Journal_Header_Running_Number__c();
        setting.Name = 'Next Running Number';
        setting.Running_Number__c = 001;
        insert setting;
    
        List<GL_Combination_Setting__c> combinationLst = new List<GL_Combination_Setting__c>();
        GL_Combination_Setting__c gls1 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11111',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Cash',
                                                                       Lookup_Code__c = 'FAB BANK - AED CURRENT ACCOUNT',
                                                                       Lookup_Code_Meaning__c = 'FAB Bank - AED Current Account',
                                                                       Payment_Currency__c = 'AED',
                                                                       Related_Object__c = 'Receipt');
        combinationLst.add(gls1);
        GL_Combination_Setting__c gls2 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11112',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Cash',
                                                                       Lookup_Code__c = 'FAB BANK - USD CURRENT ACCOUNT',
                                                                       Lookup_Code_Meaning__c = 'FAB Bank - USD Current Account',
                                                                       Payment_Currency__c = 'USD',
                                                                       Related_Object__c = 'Receipt');
        combinationLst.add(gls2);
        GL_Combination_Setting__c gls3 = new GL_Combination_Setting__c(RecordTypeId =Schema.sObjectType.GL_Combination_Setting__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                                       Account_Type__c = 'Asset',
                                                                       Code__c = '11221',
                                                                       Active__c = true,
                                                                       Journal_Entry_Account__c = 'Unapplied',
                                                                       Lookup_Code__c = 'UNAPPLIED RECEIPTS',
                                                                       Lookup_Code_Meaning__c = 'Unapplied Receipts',
                                                                       Payment_Currency__c = 'AED; USD',
                                                                       Related_Object__c = 'Invoice; Receipt');
        combinationLst.add(gls3);
        INSERT combinationLst;
        
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
        
        
        
        List<Receipt__c> receipts = TestClassUtility.createReceipt(1, acc);
        receipts[0].Gl_date__c = system.today().addDays(-20);
        receipts[0].Payment_Method__c = 'Credit Card';
        receipts[0].Payment_Currency__c = 'USD';
        receipts[0].Transaction_Reference__c = 'TRTEST123';
        receipts[0].Oracle_Receipt_Id__c = '';
        receipts[0].Entity__c = acc[0].Id;
        receipts[0].Status__c = 'Success';
        insert receipts;
        
        
        Test.startTest();
            Database.executeBatch(new Batch_CreateDecReceiptJVs());
        Test.stopTest();
    }
    
}