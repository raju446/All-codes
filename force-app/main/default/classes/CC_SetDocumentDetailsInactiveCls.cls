/*
    Author      : Kim Noceda
    Date        : 20-Mar-2017
    Description : Custom code to Update related document detail to Inactive.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_SetDocumentDetailsInactiveCls implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c !=null && step.HexaBPM__SR__r.HexaBPM__Customer__c !=null){
            System.debug('@@SRCUSTOMER: '+step.HexaBPM__SR__r.HexaBPM__Customer__c);
            System.debug('@@SRRECTYPE: '+step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c);
            Account objAcct = new Account();
            if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'EChannel_Cancellation'){
                objAcct.Id = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                objAcct.EChannel_Status__c = 'Inactive';
            }else if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Establishment_Card_Cancellation'){
                objAcct.Id = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                objAcct.Establishment_Card_Status__c = 'Cancelled'; 
            }
            
        
            Set<String> documentTypes = new Set<String>();
            for(Cancellation_SRs_Document_Types__c cancelSRMap : Cancellation_SRs_Document_Types__c.getAll().values()){
                if(cancelSRMap.Service_Request_Recordtype_API__c == step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c){
                    documentTypes.add(cancelSRMap.Document_Type__c);
                }
            }
            
            List<Document_Details__c> docDetailList = new List<Document_Details__c>();
            for(Document_Details__c docDetails : [SELECT Id, Document_Status__c, Document_Cancel_Date__c FROM Document_Details__c WHERE Account__c = :step.HexaBPM__SR__r.HexaBPM__Customer__c AND Document_Type__c IN: documentTypes]){
                docDetails.Document_Status__c = 'Cancelled';
                docDetails.Document_Cancel_Date__c = System.today(); 
                docDetailList.add(docDetails);
            }
            
            try{
                System.debug('@@OBJACCT: '+objAcct);
                if(objAcct.Id != null){
                    update objAcct;
                }
                
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