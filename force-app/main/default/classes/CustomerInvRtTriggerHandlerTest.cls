@isTest
public class CustomerInvRtTriggerHandlerTest{
    static testMethod void TestMethod1(){
        Operating_Unit__c ou = new Operating_Unit__c();
        ou.Operating_Unit_Name__c = 'ADGM Academy OU';
        ou.Oracle_Site_Id__c = '501';
        ou.OU_Abbreviation__c = 'Academy';
        insert ou;
        
        Account acc = new Account();
        acc.Name = 'Test Academy Entity';
        acc.Operating_Unit__c = ou.Id;
        insert acc;
        
        Customer_Invoice_Receipt__c CIR = new Customer_Invoice_Receipt__c();
        CIR.Entity__c = acc.Id;
        insert CIR;
        
        Customer_Invoice_Receipt__c CIR2 = new Customer_Invoice_Receipt__c();
        insert CIR2;
        
        CIR2.Entity__c = acc.Id;
        update CIR2;
        
    }
}