@isTest
public class OpportunityTriggerTest{
    static testMethod void validateOpportunityTrigger() {
        // Create an account with an opportunity, 
        Account acct = new Account(Name='Test Account');
        insert acct;
        Opportunity opp = new Opportunity(Name='Test Opportunity',
                                       StageName='Pre-Application',
                                       CloseDate=System.today().addMonths(2),
                                       AccountId=acct.Id);
        insert opp;
        opp.Application_Fee__c = 20.0;
        opp.Application_Fee_Payment_Date__c = System.today();
        opp.Application_Submitted_Date__c =  System.today();
        opp.Country_of_Origin_of_Parent__c = 'INDIA';
        opp.StageName = 'Application';
        opp.ADGM_Company__c = 'NO';
        opp.Start_up__c = 'NO';
        update opp;
        opp.In_Principle_Requirements_Completed__c = 'Yes';
        opp.StageName = 'In-Principle';
        update opp;
        opp.Date_of_FSP__c = System.today();
        opp.Date_of_IPA_Conditions_Completion__c = System.today(); 
        opp.StageName = 'Authorised';
        update opp;  
        
    }
}