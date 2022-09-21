@isTest
global class studentupdateTest{
@isTest 
static void check()
 {
 list<student2__c> qlist = new list<student2__c>();
 {
 for(student2__c q:qlist)
 {
  if(q.gender__c=='female')
 q.gender__c='female';
  update qlist;
  }
  
  Test.startTest();
  studentupdate jk = new studentupdate();
  Database.executeBatch(jk);
  Test.stopTest();
  }
    }
    }