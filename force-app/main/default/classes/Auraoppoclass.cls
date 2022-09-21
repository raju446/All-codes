public with sharing class Auraoppoclass 
{
    @AuraEnabled
    public static list<Opportunity> getRelatedList(Id recordId)
    {
        List<Opportunity> Oppolist = [Select id, name, CloseDate, StageName from Opportunity where AccountId=:recordId And StageName='Prospecting'];
        return Oppolist;
    }
    @AuraEnabled
      public static void createOpportunity(){
        List<Opportunity> accs=new List<Opportunity>();
            Opportunity a1=new Opportunity();
            a1.Name='New Oppo';
            a1.CloseDate=Date.today();
           a1.StageName='Prospecting';
            a1.AccountId='0015g00000lcQl7AAE';
            
            accs.add(a1);
        
        insert accs;
   }
}