@isTest
public class Accountamounttest {
    @isTest static void Accountamount() {
      Account Acc = new Account();
        Acc.Name = 'raju';
        Acc.Total__c = 100;     
        insert Acc;
        contact cn = new contact();
        cn.AccountId = Acc.Id;
        cn.Lastname = 'Test';
        insert cn;
        Acc.Total__c = 150;
        update Acc;
        
  }   
}