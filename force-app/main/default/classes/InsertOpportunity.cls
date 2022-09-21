public class InsertOpportunity {
 @AuraEnabled
    public static void createOpportunity(){ 
            Opportunity a1=new Opportunity();
            a1.Name='New Opp';
			a1.StageName = 'Prospecting';
       		a1.CloseDate = system.today();
          
        
        
        insert a1;
     
    }
}