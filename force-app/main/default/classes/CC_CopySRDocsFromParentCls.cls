/*
    Author      : Kim Noceda
    Date        : 17-Oct-2017
    Description : Custom code to copy SR Docs from Parent SR to Sub SR.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_CopySRDocsFromParentCls implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        System.debug('**SR: '+step.HexaBPM__SR__c);
        System.debug('**SR: '+step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c);
        System.debug('**SR: '+step.HexaBPM__SR__r.HexaBPM__Parent_SR__c);
        //check if the sr is a permit entertainment and the parent sr field is not null
        if(step.HexaBPM__SR__c !=null && 
            step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Permit_Entertainment' && 
            step.HexaBPM__SR__r.HexaBPM__Parent_SR__c != null){
            
            //query all fields on SR Docs related to the Parent SR
            String querySRDocsStr = queryAllSRDocs(step.HexaBPM__SR__r.HexaBPM__Parent_SR__c);
            List<HexaBPM__SR_Doc__c> srDocList = Database.query(querySRDocsStr );
            Set<Id> srDocIds = new Set<Id>();
            
            //iterate on the SR docs and put in a set of Ids
            Map<String,Id> srDocMapping = new Map<String,Id>();
            for(HexaBPM__SR_Doc__c srDoc : srDocList){
                srDocIds.add(srDoc.Id);
            }
            
            //query all fields on SR Docs related to the Sub SR
            String querySRDocsStrChild = queryAllSRDocs(step.HexaBPM__SR__c);
            List<HexaBPM__SR_Doc__c> srDocListChild = Database.query(querySRDocsStrChild);
            
            try{
                
                //iterate on the Sub SR documents
                for(HexaBPM__SR_Doc__c srd :srDocListChild){
                    srDocMapping.put(srd.HexaBPM__Document_Name__c, srd.Id);
                    srd.HexaBPM__Status__c = 'Uploaded';
                }
                
                system.debug('@@SRMAPPING: '+srDocMapping);
                system.debug('@@SRATTACHMENTS: '+[Select Id, Name FROM Attachment WHERE ParentId IN :srDocIds]);
                
                //iterate on the attachments of the parent sr docs and clone. Attached it to the Sub SR documents
                List<Attachment> newAttachments = new List<Attachment>();
                for(Attachment att : [Select Id, Body, Name, Description, ParentId FROM Attachment WHERE ParentId IN :srDocIds]){
                    Attachment newAtt = att.clone();
                    newAtt.ParentId = srDocMapping.get(att.Name);
                    newAttachments.add(newAtt);
                }
                
                //insert records
                if(!newAttachments.isEmpty()){
                    insert newAttachments;
                }
                
                //update sr docs for the status
                if(!srDocListChild.isEmpty()){
                    update srDocListChild;
                }
                
            } catch(Exception e){
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
    //method to create sosl string for SR Document
    global string queryAllSRDocs(Id srId){
      String queryStr = 'SELECT ';
      Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('HexaBPM__SR_Doc__c').getDescribe().fields.getMap();
      for(String s : objectFields.keySet()) {
         queryStr += ' ' + s + ', ';
      }
       queryStr = queryStr.subString(0,queryStr.Length()-2);
       queryStr += ' FROM HexaBPM__SR_Doc__c';
       queryStr += ' WHERE HexaBPM__Service_Request__c = \''+srId+'\'';
       
       return queryStr;
    }
}