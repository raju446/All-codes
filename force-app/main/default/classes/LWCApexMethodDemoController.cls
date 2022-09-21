public inherited sharing class LWCApexMethodDemoController {
    @AuraEnabled(Cacheable = true)
    public static List<Account> getAccounts(){
      return [SELECT Id, Name, Phone, AccountNumber, Industry, CreatedDate FROM Account ORDER BY createddate DESC  Limit 10];
    }
}