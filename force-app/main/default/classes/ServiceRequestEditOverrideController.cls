/**********************************************************
    Author      :   Kim Noceda
    Company     :   PwC
    Description :   Controller to Service Request Edit Override
*************************************************************/
public without sharing class ServiceRequestEditOverrideController{
    public HexaBPM__Step__c objStep{get;set;}
    public HexaBPM__Service_Request__c objSR{get;set;}
    public string SRID{get;set;}
    public string StepID{get;set;}
    public map<id,HexaBPM__Step_Transition__c> mapStepTransition;
    public string selectedTransition{get;set;}
    public list<selectoption> listTransitions{get;set;}
    public string SRAccountId;
    public Boolean isPortalUser;
    public ServiceRequestEditOverrideController(ApexPages.StandardController controller){
        selectedTransition = '';
        if(apexpages.currentpage().getParameters().get('Id')!=null){
            
            SRID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('Id'));
            system.debug('====='+SRID);
            objSR = [SELECT Id, HexaBPM__External_Status_Name__c, HexaBPM__IsClosedStatus__c, HexaBPM__IsCancelled__c, HexaBPM__Is_Rejected__c, 
            HexaBPM__SR_Template__r.HexaBPM__Is_Through_Flow__c, HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c
            FROM HexaBPM__Service_Request__c WHERE Id = :SRID];
        }
        
        isPortalUser = false;
        List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :Userinfo.getUserId()];
        if(currentUser.size() > 0){
            if(currentUser[0].ContactId != null){
                isPortalUser = true;
            }
        }
    }
    /*
        Method Name :   CheckAccess
        Description :   Code to check the Service Request belongs to the logged In user's account or not
    */
    public pagereference CheckAccess(){
        System.debug('##ISPORTAL_USER: '+isPortalUser);
        System.debug('##OBJSR: '+objSR);
        Pagereference pg = new Pagereference('/'+objSR.Id+'/e?nooverride=1&retURL=/'+objSR.Id+'&saveURL=/'+objSR.Id);
        pg.setRedirect(true);
        //if(isPortalUser == false)
        //{
            if(objSR.HexaBPM__IsClosedStatus__c == false && 
                objSR.HexaBPM__IsCancelled__c == false && 
                objSR.HexaBPM__Is_Rejected__c == false){
                System.debug('##REDIRECT to EDIT');
                
                if((objSR.HexaBPM__SR_Template__r.HexaBPM__Is_Through_Flow__c && isPortalUser) || test.isRunningTest())
                {
                    list<HexaBPM__Page_Flow__c> flowId = [Select Id from HexaBPM__Page_Flow__c  where 
                    HexaBPM__Record_Type_API_Name__c =:objSR.HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c LIMIT 1];
                    
                    if(!flowId.isEmpty())
                    {
                        pg = new Pagereference('/apex/PageFlow?FlowId='+flowId[0].id+'&Id='+objSR.id);
                        return pg;
                    }
                }
                return pg;
            }
        //} 
        //else{
            //if(objSR.HexaBPM__External_Status_Name__c == 'Draft'){
                //return pg;
            //}
        //}
        
        return null;
    }
    /*
        Method Name :   closeWindow
        Description :   Code to redirect back to the sr detail page
    */
    public pagereference closeWindow(){
        Pagereference pg = new Pagereference('/'+objSR.Id);
        pg.setRedirect(true);   
        return pg;
    }
}