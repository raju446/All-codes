public class OpportunityAcc {
@AuraEnabled
 public static List <Opportunity > oppoAccounts(id recordId) {
List<Opportunity > accList = [SELECT Id, Name, StageName, CloseDate from Opportunity  where StageName = 'Prospecting'];
return accList;
}
     public static void createAcc(Opportunity acc) {
        insert acc;
 }
}