/*
    Author      : Kim Noceda
    Date        : 15-Apr-2018
    Description : Controller class for MultipleInitalApproval page. 
    --------------------------------------------------------------------------------------
*/
public without sharing class MultipleInitialApprovalSRController{

    public String accountId{get;set;}
    public String latestOpenCIDSR{get;set;}
    public Boolean hasMultiple{get;set;}
    public List<HexaBPM__Service_Request__c> objSRList{get;set;}
    
    public MultipleInitialApprovalSRController(ApexPages.StandardController controller){
        accountId = Apexpages.currentpage().getparameters().get('id');
        latestOpenCIDSR = '';
        hasMultiple = false;
        objSRList = new List<HexaBPM__Service_Request__c>();
        objSRList = [SELECT Id, Name, CreatedById, CreatedDate, HexaBPM__External_Status_Name__c, LastModifiedById, LastModifiedDate FROM HexaBPM__Service_Request__c 
                        WHERE HexaBPM__Customer__c = :accountId 
                        AND HexaBPM__Record_Type_Name__c = 'Initial_Approval' 
                        AND HexaBPM__IsCancelled__c <> TRUE 
                        AND HexaBPM__Is_Rejected__c <> TRUE
                        AND HexaBPM__IsClosedStatus__c <> TRUE 
                        ORDER BY CreatedDate DESC];
        
        System.debug('@@SRLIST: '+objSRList);
        if(objSRList.size() > 0){
            hasMultiple = true;
            //latestOpenCIDSR = objSRList[0].Name;
        }
    }
}