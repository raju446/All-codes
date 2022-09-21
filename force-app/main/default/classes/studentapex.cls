public class studentapex {
    @AuraEnabled
    public static List<student2__c>  retrieveContactData(String searchKey) {
        String gender =  + searchKey + '%';
        return [SELECT id,name,gender__c,marks__c,fees__c,results__c,teacher2__r.name FROM student2__c WHERE teacher2__r.name=:searchKey];
    }
}