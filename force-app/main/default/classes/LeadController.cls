public class LeadController {
    @AuraEnabled
    public static UserLead getUserLead(string leadId) {
        User user = [select Profile.Name FROM User Where id =: userInfo.getUserId()];
        Lead lead = [SELECT Company,Lead_City__c,Lead_Country__c,Lead_Street__c,Lead_Zip_Postal_Code__c,State_Province__c,Country_Code__c,Primary_Phone_Number_Country_Code_1__c,Primary_Phone_Number_1__c,MobilePhone,Mobile_Country_Code__c FROM Lead where id = :leadId];
        UserLead userLead = new UserLead();
        if(user != null && lead != null){
            userLead.lead = lead;
            userLead.user = user;
        }
        return userLead;//
    }
    @AuraEnabled
    public static User getUserInfo(){
        User user = [select Profile.Name FROM User Where id =: userInfo.getUserId()];
        return user;
    }
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }
    public class UserLead{
        @AuraEnabled
        public Lead lead {get;set;}
        @AuraEnabled
        public User user {get;set;}
    }  
}