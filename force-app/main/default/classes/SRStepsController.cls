public without sharing class SRStepsController{
    public list<HexaBPM__Step__c> lstSRSteps {get;set;}
    public SRStepsController(){
        string srID = ApexPages.currentPage().getParameters().get('id');
        User user =  [select contact.AccountId from user where id=:userinfo.getuserid()];
        if(user != null) {
            lstSRSteps = new list<HexaBPM__Step__c>();
            lstSRSteps = [select Name, HexaBPM__Summary__c, HexaBPM__Step_Notes__c, Current_Step_Status__c
                 from HexaBPM__Step__c where HexaBPM__SR__c= :srID and Owner.Name = 'Client' and HexaBPM__SR__r.HexaBPM__Customer__c = :user.contact.AccountId];
        }
    }
}