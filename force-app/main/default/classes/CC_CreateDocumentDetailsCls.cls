/*
    Author      : Kim Noceda
    Date        : 27-Feb-2018
    Description : Custom code to create Document Details based on the mapping and will be attached to account.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_CreateDocumentDetailsCls implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c!=null && step.HexaBPM__SR__r.HexaBPM__Customer__c!=null){
            createDocDetails(step.HexaBPM__SR__c);
        }
        return strResult;
    }
    
    global static string queryAllSRFields(Id srId){
        String queryStr = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('HexaBPM__Service_Request__c').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
           queryStr += ' ' + s + ', ';
        }
        queryStr = queryStr.subString(0,queryStr.Length()-2);
        queryStr += ' FROM HexaBPM__Service_Request__c';
        queryStr += ' WHERE Id = \''+srId+'\'';
        
        return queryStr;
    }
    
    @future
    global static void createDocDetails(String srId){
        String querySRStr = queryAllSRFields(srId);
        HexaBPM__Service_Request__c objSR = Database.query(querySRStr);
        
        Set<String> docLetterTypes = new Set<String>{'No Objection Certificate','Government Correspondence','Letter', 'Permit', 'CID Approval Letter'};
        Map<String, HexaBPM__SR_Doc__c> srDocMap = new Map<String, HexaBPM__SR_Doc__c>();
        /*List<HexaBPM__SR_Doc__c> srDocList = [SELECt Id, Document_Number__c 
                                                FROM HexaBPM__SR_Doc__c WHERE HexaBPM__Service_Request__c = :objSR.Id];
        system.debug('@@SRDOCLIST: '+srDocList);*/
        for(HexaBPM__SR_Doc__c srDoc : [SELECT Id, Letter_Type__c, Document_Number__c 
                                        FROM HexaBPM__SR_Doc__c 
                                        WHERE Exclude_from_Running_Number__c = FALSE 
                                        AND HexaBPM__Service_Request__c = :objSR.Id 
                                        AND Letter_Type__c IN :docLetterTypes 
                                        AND Document_Number__c <> null]){
            srDocMap.put(srDoc.Letter_Type__c, srDoc);
        }
        
        System.debug('@@SRDOCMAP: '+srDocMap);
    
        //creates a map for the field mapping for SR and Document Detail fields from the custom setting
        Map<String, String> mapDocDetailSRField = new Map<String, String>();
        Map<String, List<Document_Detail_SR_Field_Mapping__c>> mapDocDetailDocType = new Map<String, List<Document_Detail_SR_Field_Mapping__c>>();
        
        
        for(Document_Detail_SR_Field_Mapping__c docDetailSRFieldMap : Document_Detail_SR_Field_Mapping__c.getAll().values()){
            if(objSR.HexaBPM__Record_Type_Name__c == docDetailSRFieldMap.Service_Request_Recordtype_API__c){
                if(docDetailSRFieldMap.Active__c == TRUE){
                    mapDocDetailSRField.put(docDetailSRFieldMap.SR_Field_API_Name__c, docDetailSRFieldMap.Document_Detail_Field_API_Name__c);
                    if(mapDocDetailDocType.containskey(docDetailSRFieldMap.Document_Type__c)){
                        mapDocDetailDocType.get(docDetailSRFieldMap.Document_Type__c).add(docDetailSRFieldMap);
                    } else{
                        List<Document_Detail_SR_Field_Mapping__c> newDocTypeList = new List<Document_Detail_SR_Field_Mapping__c>();
                        newDocTypeList.add(docDetailSRFieldMap);
                        mapDocDetailDocType.put(docDetailSRFieldMap.Document_Type__c, newDocTypeList);
                    }
                }
            }
        }
        
        System.debug('@@DOCDETAILMAP: '+mapDocDetailDocType);
        
        //create Map for Document Detail recordtype
        Map<String, Id> documentDetailRecTypeMap = new Map<String, Id>();
        for(Recordtype rt : [SELECT Id, DeveloperName, Name FROM Recordtype WHERE SObjectType = 'Document_Details__c']){
            documentDetailRecTypeMap.put(rt.Name, rt.Id);
        }
        System.debug('@@RECORDTYPEMAP: '+documentDetailRecTypeMap);
        List<Document_Details__c> docDetailToBeInserted = new List<Document_Details__c>();
        
        for(String key : mapDocDetailDocType.keyset()){
            Document_Details__c objDocDetail = new Document_Details__c();
            objDocDetail.Account__c = objSR.HexaBPM__Customer__c;
            objDocDetail.Document_Type__c = key;
            if(documentDetailRecTypeMap.containskey(key)){
                objDocDetail.RecordtypeId = documentDetailRecTypeMap.get(key);
            }
            objDocDetail.Document_Status__c = 'Active';
            String letterTypeStr = '';
            for(Document_Detail_SR_Field_Mapping__c ddSR : mapDocDetailDocType.get(key)){
                objDocDetail.put(mapDocDetailSRField.get(ddSR.SR_Field_API_Name__c), objSR.get(ddSR.SR_Field_API_Name__c));
                letterTypeStr = ddSR.SR_Doc_Letter_Type__c;
            }
            System.debug('@@LETTERTYPE: '+letterTypeStr);
            System.debug('@@SRDOCMAPKEYSET: '+srDocMap.keyset());
            if(srDocMap.containskey(letterTypeStr)){
                objDocDetail.Document_Number__c = srDocMap.get(letterTypeStr).Document_Number__c;
            }
            docDetailToBeInserted.add(objDocDetail);
        }
        system.debug('@@DOCDETAIL-LIST: '+docDetailToBeInserted);
        
        try{
            
            insert docDetailToBeInserted;
            
        } catch(Exception e){
            //strResult = e.getMessage();
            System.debug('##ERROR: ' +e.getMessage());
        }
    }
}