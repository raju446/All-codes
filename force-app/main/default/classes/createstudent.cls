public with sharing class createstudent {

    /*Using multiple parameter in apex  controller */
    @AuraEnabled
    public static hotel__c submitScoreAction(string name,string hotelname,string food,integer foodcost){
        hotel__c student = new hotel__c();
        student.Name=Name;
        student.HOTEL_NAME__c=hotelname;
        student.food__c=food;
         student.food_cost__c=foodcost;
        
        system.debug('raj'+student);

        insert student;
        return student;
    }
}