public class Opportunitys {
      @AuraEnabled
    public static List <Opportunity > fetchAccounts(id recordId) {
        //Qyery 10 accounts
        List<Opportunity > accList = [SELECT Id, Name,StageName,CloseDate from Opportunity  where StageName = 'Prospecting' and AccountId =: recordId];
       // String s2 = System.Label.Opportunity_Label;
        //return list of accounts
      
        return accList;
        
    }
}
      /* public static Opportunity createCon(){
        Opportunity con = new Opportunity(Name='test');
        insert con;
        return con;
    }
    
    }*/
    
    
  /* public static void createOpportunity(){ 
            Opportunity a1=new Opportunity();
            a1.Name='New Opp';
			a1.StageName = 'Prospecting';
       		a1.CloseDate = system.today();
          
        
        
        insert a1;
 system.debug ('a>................' + a1);
        
}*/
//}