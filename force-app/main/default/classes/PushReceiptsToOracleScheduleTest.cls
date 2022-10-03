@isTest
private class PushReceiptsToOracleScheduleTest{
    static testMethod void pushReceiptsTest1(){
        Exchange_Rate__c er = new Exchange_Rate__c(USD_To_AED_Conversion_Rate__c = 3.6725,Conversion_Date__c = Date.today());
        insert er;
        OU_Basd_Invoice_Running_Number__c rn = new OU_Basd_Invoice_Running_Number__c(name = 'fsra',Operating_Unit__c = '103', Type__c = 'Receipt',Running_Number__c =1);
        insert rn;
        Account[] acc = TestClassUtility.createAccounts(1);
        acc[0].Oracle_Party_Id__c = '123';
        acc[0].Source_System_Name__c = 'FSRA';
        acc[0].Oracle_site_id__c = '103';
        insert acc;
        Receipt__c objReceipt = new Receipt__c();
        objReceipt.Amount__c = 2000;
        objReceipt.Status__c = 'Success';
        objReceipt.Oracle_Receipt_Id__c = null;
        objReceipt.Entity__c = acc[0].Id;
        insert objReceipt;
            
        test.startTest();
            PushReceiptsToOracleSchedule receiptSched = new PushReceiptsToOracleSchedule();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, receiptSched);
        test.stopTest();

    }
}