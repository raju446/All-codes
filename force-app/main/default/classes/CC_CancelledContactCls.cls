/*
    Author      : Kim Noceda
    Date        : 25-Feb-2017
    Description : Custom code to Update contact status to cancelled and the related document detail to Inactive.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_CancelledContactCls implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c !=null && step.HexaBPM__SR__r.HexaBPM__Contact__c !=null){
            
            Contact objCon = new Contact(Id = step.HexaBPM__SR__r.HexaBPM__Contact__c);
            if(step.HexaBPM__SR__r.Dependent__c!=null){
                objCon = new Contact(Id = step.HexaBPM__SR__r.Dependent__c);
            }if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_Cancellation'){
                objCon.Dependent_Status__c= 'Cancelled';
            } else{
                objCon.Employment_Status__c = 'Cancelled';
            }
            
            Set<String> documentTypes = new Set<String>();
            for(Cancellation_SRs_Document_Types__c cancelSRMap : Cancellation_SRs_Document_Types__c.getAll().values()){
                if(cancelSRMap.Service_Request_Recordtype_API__c == step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c){
                    documentTypes.add(cancelSRMap.Document_Type__c);
                }
            }
            
            List<Document_Details__c> docDetailList = new List<Document_Details__c>();
            for(Document_Details__c docDetails : [SELECT Id, Document_Status__c FROM Document_Details__c WHERE Contact__c = :objCon.Id AND Document_Type__c IN: documentTypes]){
                docDetails.Document_Status__c = 'Cancelled';
                docDetails.Document_Cancel_Date__c = System.today();
                docDetailList.add(docDetails);
            }
            
            try{
                update objCon;
            
                if(!docDetailList.isEmpty()){
                    update docDetailList;
                }
            } catch(Exception e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
}