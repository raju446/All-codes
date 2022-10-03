public without sharing class SRDocController{
    public list<HexaBPM__SR_Doc__c> lstSRDocs {get;set;}
    public SRDocController(){
        string srID = ApexPages.currentPage().getParameters().get('id');
        User user =  [select contact.AccountId from user where id=:userinfo.getuserid()];
        lstSRDocs = new list<HexaBPM__SR_Doc__c>(); 

        Set<Id> srStepsCreated = new Set<Id>();
        for(HexaBPM__Service_Request__c ObjSR:[Select Id,HexaBPM__IsClosedStatus__c,Show_Work_Permit__c,
                                                (select Available_to_Community__c,HexaBPM__Document_Name__c,HexaBPM__Document_Description_External__c, HexaBPM__Is_Not_Required__c, Available_to_Community_on_Step__c, 
                                                HexaBPM__Status__c, Preview_Download_Document__c,Participant_Name__c, HexaBPM__Sys_IsGenerated_Doc__c from HexaBPM__SR_Docs__r), 
                                                (select id, HexaBPM__SR_Step__c FROM HexaBPM__Steps_SR__r)
                                                from HexaBPM__Service_Request__c 
                                                where Id=:srID 
                                                and HexaBPM__Customer__c = :user.contact.AccountId]){
            System.debug('##SR--CLOSED: '+ObjSR.HexaBPM__IsClosedStatus__c);
            if(ObjSR.HexaBPM__Steps_SR__r != null){
                for(HexaBPM__Step__c step : ObjSR.HexaBPM__Steps_SR__r){
                    srStepsCreated.add(step.HexaBPM__SR_Step__c);
                }
            }
            system.debug('@@STEPS: '+srStepsCreated);
            if(ObjSR.HexaBPM__SR_Docs__r!=null){
                for(HexaBPM__SR_Doc__c doc : ObjSR.HexaBPM__SR_Docs__r){
                    System.debug('##SRDOC: '+doc.HexaBPM__Document_Name__c+' -- '+doc.Available_to_Community__c);
                    if(doc.Available_to_Community__c || ObjSR.Show_Work_Permit__c){
                        if(doc.Available_to_Community_on_Step__c == null || doc.Available_to_Community_on_Step__c == ''){
                            lstSRDocs.add(doc);
                        } else{
                            if(srStepsCreated.contains(doc.Available_to_Community_on_Step__c)){
                                lstSRDocs.add(doc);
                            }
                        }
                    }
                }
            }
        }
    }
}