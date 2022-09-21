public class Getteacher2Andstudent2 {

     @AuraEnabled
    public static List<teacher2__c> getteacher2Records() {
        return new List<teacher2__c>([Select id,Name from teacher2__c LIMIT 100]);
    }
    @AuraEnabled
    public static List<student2__c> getstudent2Records(string teacher2Id) {
        return new List<student2__c>([Select id,Name,results__c,gender__c,marks__c from student2__c]);
    }
}