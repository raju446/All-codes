public class OpportunityList{
      @AuraEnabled
      public  Id accountid;
    public  List<Account> fetchAccounts;
          public void contactFieldsConcat(Id accid){
        
        accountid = accid;
              
string query ='select id, name, (select id, name, CloseDate, StageName from Opportunity) from account where id =: '+accountid;
        fetchAccounts = Database.query(query);
        system.debug(fetchAccounts);
}

}
    
    
  /* public static void createOpportunity(){ 
            Opportunity a1=new Opportunity();
            a1.Name='New Opp';
            a1.StageName = 'Prospecting';
            a1.CloseDate = system.today();
          
        
        
        insert a1;
 system.debug ('a>................' + a1);
        
}*/
//}