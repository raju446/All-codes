/******************************************************************************************
*  Author         :   Durga
*  Company        :   PwC
*  Date           :   24-Oct-2017
*  Description    :   Apex Controller for Stepp Owner Assignment Page
*  Version        :   1.0
********************************************************************************************/
public without sharing class StepOwnerAssignmentController {
    public HexaBPM__Step__c step;
    public string SRID{get;set;}
    public string StepID{get;set;}
    public string ActionType;
    public StepOwnerAssignmentController(ApexPages.StandardController controller){
        if(apexpages.currentpage().getParameters().get('Id')!=null)
            SRID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('Id'));
        if(apexpages.currentpage().getParameters().get('ActionType')!=null)
            ActionType = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('ActionType'));
        if(apexpages.currentpage().getParameters().get('StepId')!=null){
            StepID = String.escapeSingleQuotes(apexpages.currentpage().getParameters().get('StepId'));
            step = new HexaBPM__Step__c();
            for(HexaBPM__Step__c stp:[Select Id,OwnerId,Sys_SR_Step_Owner_Id__c from HexaBPM__Step__c where Id=:StepID]){
                step = stp;
            }
        }
    }
    public void DoAction(){
        if(ActionType!=null && ActionType=='Assign'){
            string strResult = StepOwnerChangeCls.AcceptStep(step.Id,step.OwnerId);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info,strResult));
        }else if(ActionType!=null && ActionType=='Release'){
            string strResult = StepOwnerChangeCls.ReleaseStep(step.Id,step.OwnerId,step.Sys_SR_Step_Owner_Id__c);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Info,strResult));
        }
    }
    public pagereference CloseWindow(){
        Pagereference pg = new Pagereference('/'+SRID);
        pg.setredirect(true);
        return pg;
    }
}