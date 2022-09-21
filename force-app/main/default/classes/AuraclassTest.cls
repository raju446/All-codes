@isTest
public class AuraclassTest {
    @istest static void getRelatedList_test(){
        
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
        
        list<Opportunity> lop = new list<Opportunity>();
        
        Auraclass.getRelatedList(acc.id);
        Auraclass.createOpportunity();
       // OpportunityController.createCon();
        
        
        Test.stopTest();
    }

}