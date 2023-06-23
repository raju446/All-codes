public class Booksearch {
 
    @AuraEnabled( cacheable = true )
    public static List< host_test_data__c > fetchBooks() {
     
        return [
            SELECT Id__c,Title__c,notes__c,Inventory__c,Category__c,ISBN__c,Author__c
            FROM host_test_data__c
            LIMIT 10
        ];
         
    }
     
}