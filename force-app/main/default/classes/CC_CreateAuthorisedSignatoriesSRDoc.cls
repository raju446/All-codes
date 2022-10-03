/*
    Author      : Kim Noceda
    Date        : 14-Mar-2018
    Description : Custom code to create SR Documents for CID Approval from the Authorised Signatories of the Entity.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_CreateAuthorisedSignatoriesSRDoc implements HexaBPM.iCustomCodeExecutable { 
     global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c != null && step.HexaBPM__SR__r.HexaBPM__Customer__c != null){
            List<HexaBPM__SR_Doc__c> insertSRDocList = new List<HexaBPM__SR_Doc__c>();
            insertSRDocList = insertAuthorisedSignatoriesSRDOC(step.HexaBPM__SR__r);
            System.debug('@@SRDOC: '+insertSRDocList);
            if(!insertSRDocList.isEmpty()){
                try{
                    insert insertSRDocList;
                } catch(Exception e){
                    strResult = e.getMessage();
                }   
            }
        }
        
        return strResult;
     }
     
     global List<HexaBPM__SR_Doc__c> insertAuthorisedSignatoriesSRDOC(HexaBPM__Service_Request__c objSR){
        List<HexaBPM__SR_Template_Docs__c> srTempDocList = new List<HexaBPM__SR_Template_Docs__c>();
        srTempDocList = [Select Id,HexaBPM__Added_through_Code__c,HexaBPM__Document_Master__c,HexaBPM__Document_Master__r.Name,
                                        HexaBPM__Document_Master_Code__c,HexaBPM__SR_Template__c,HexaBPM__Document_Description_External__c,HexaBPM__Optional__c from HexaBPM__SR_Template_Docs__c 
                                        WHERE HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c=:'Initial_Approval' 
                                        AND HexaBPM__SR_Template__r.HexaBPM__Active__c = true 
                                        AND HexaBPM__On_Submit__c = true and HexaBPM__Added_through_Code__c=true];
        
        List<HexaBPM__SR_Doc__c> insertSRDocList = new List<HexaBPM__SR_Doc__c>();// 
        for(Role__c objRole : [SELECT Id, Type__c, Subject_Account__c,Forenames__c,Surname__c,Nationality__c FROM Role__c WHERE Subject_Account__c=:objSR.HexaBPM__Customer__c AND Type__c='Authorised Signatory' AND Status__c = 'Active']){
            for(HexaBPM__SR_Template_Docs__c objSRTempDoc : srTempDocList){
                if(objSRTempDoc.HexaBPM__Document_Master_Code__c == 'VALID_VISA_COPY' || objSRTempDoc.HexaBPM__Document_Master_Code__c == 'EMIRATES_ID'){
                    if(objRole.Nationality__c == 'UNITED ARAB EMIRATES'){
                        HexaBPM__SR_Doc__c srDoc = new HexaBPM__SR_Doc__c();
                        srDoc.HexaBPM__From_Finalize__c = true;
                        srDoc.HexaBPM__Is_Not_Required__c = objSRTempDoc.HexaBPM__Optional__c;
                        srDoc.Authorised_Signatory_Name__c = objRole.Forenames__c + ' ' +objRole.Surname__c;
                        srDoc.Name = objSRTempDoc.HexaBPM__Document_Master__r.Name;
                        srDoc.HexaBPM__Document_Master__c = objSRTempDoc.HexaBPM__Document_Master__c;
                        srDoc.HexaBPM__Service_Request__c = objSR.Id;
                        srDoc.HexaBPM__SR_Template_Doc__c = objSRTempDoc.Id;
                        srDoc.HexaBPM__Status__c = 'Pending Upload';
                        srDoc.HexaBPM__Document_Description_External__c = objSRTempDoc.HexaBPM__Document_Description_External__c;
                        insertSRDocList.add(srDoc);
                    }
                }else{
                    HexaBPM__SR_Doc__c srDoc = new HexaBPM__SR_Doc__c();
                    srDoc.HexaBPM__From_Finalize__c = true;
                    srDoc.HexaBPM__Is_Not_Required__c = objSRTempDoc.HexaBPM__Optional__c;
                    srDoc.Authorised_Signatory_Name__c = objRole.Forenames__c + ' ' +objRole.Surname__c;
                    srDoc.Name = objSRTempDoc.HexaBPM__Document_Master__r.Name;
                    srDoc.HexaBPM__Document_Master__c = objSRTempDoc.HexaBPM__Document_Master__c;
                    srDoc.HexaBPM__Service_Request__c = objSR.Id;
                    srDoc.HexaBPM__SR_Template_Doc__c = objSRTempDoc.Id;
                    srDoc.HexaBPM__Status__c = 'Pending Upload';
                    srDoc.HexaBPM__Document_Description_External__c = objSRTempDoc.HexaBPM__Document_Description_External__c;
                    
                    insertSRDocList.add(srDoc);
                }
            }
        }
        System.debug('@@SRDOCAUTH: '+insertSRDocList);
        return insertSRDocList;
     }
}