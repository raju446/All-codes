public class studentmale {
    @AuraEnabled
    public static List <student2__c> getstudent2() {
        return [SELECT Id,name,gender__c,marks__c,fees__c,results__c FROM student2__c ORDER BY createdDate ASC];
    }    
    @AuraEnabled
    public static List<student2__c> findByname(String searchKey) {
        String name =  + searchKey + '%';
        return [SELECT id,name,gender__c,marks__c,fees__c,results__c FROM student2__c WHERE gender__c LIKE :name];
    }
}