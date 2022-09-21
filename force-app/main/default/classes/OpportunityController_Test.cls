@isTest
public class OpportunityController_Test {
    @istest static void fetchAccounts_Test(){
        
        Test.startTest();
        Account acc = new Account();
         acc.name = 'Test';
        insert acc ;
        
        Opportunity op = new Opportunity();
        op.Name = 'New Opps';
        op.StageName = 'Prospecting';
        op.CloseDate = system.today();
        op.AccountId = acc.id;

        insert op;
        
        Opportunitys opc = new Opportunitys(); 
        Opportunitys.fetchAccounts(acc.id);
       // OpportunityController.createCon();
        
        
        Test.stopTest();
    }

}