@isTest
public with sharing class PortalBalanceCalculatorTest
{
     public static testmethod void PortalBalanceCalculator_UT1()
     {
         Account[] acc = TestClassUtility.createAccounts(1);
         acc[0].Oracle_Party_Id__c = '123';
         acc[0].Source_System_Name__c = 'FSRA';
         insert acc;
         
         PortalBalanceCalculator.finalbalance(acc[0].id);
         
     }
}