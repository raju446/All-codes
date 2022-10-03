/*
    Author      : Kim Noceda
    Date        : 06-Sep-2017
    Description : Custom code to update Contact records and related Document Detail based on the mapping.
    --------------------------------------------------------------------------------------
*/
global class CC_UpdateContactCls implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c !=null && step.HexaBPM__SR__r.HexaBPM__Contact__c !=null){
        
            String querySRStr = queryAllSRFields(step.HexaBPM__SR__c);
            HexaBPM__Service_Request__c objSR = Database.query(querySRStr);
        
            Id targetContact = null;
            if(step.HexaBPM__SR__r.Sub_Menu__c == 'Employee' || step.HexaBPM__SR__r.Sub_Menu__c == 'Work Permits'){
                targetContact = step.HexaBPM__SR__r.HexaBPM__Contact__c;
            } else if(step.HexaBPM__SR__r.Sub_Menu__c == 'Dependent'){
                targetContact = step.HexaBPM__SR__r.Dependent__c;
            }
            system.debug('##TARGET: '+targetContact);
            Contact objCon = new Contact();
            if(targetContact == null){
                objCon = new Contact();
                List<Recordtype> rectype = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = 'Contact_Dependent' LIMIT 1];
                if(!rectype.isEmpty()){
                    objCon.RecordtypeId = rectype[0].Id;
                }
                objCon.Dependent_Status__c= 'Active';
                objCon.Sponsor__c = step.HexaBPM__SR__r.HexaBPM__Contact__c;
            } else{
                String queryStr = queryAllContactFields(targetContact);
                objCon = Database.query(queryStr);
            }
            
            //creates a map for the field mapping for SR and contact fields from the custom setting
            Map<String, String> mapConSRField = new Map<String, String>();
            for(Contact_SR_Field_Mapping__c cSRFieldMap : Contact_SR_Field_Mapping__c.getAll().values()){
                if(cSRFieldMap.Active__c == TRUE){
                    mapConSRField.put(cSRFieldMap.SR_Field_API_Name__c, cSRFieldMap.Contact_Field_API_Name__c);
                }
            }
            //iteratres on the map and creates the field values for the contact record
            for(String srFieldName : mapConSRField.keyset()){
                if(step.getSObject('HexaBPM__SR__r').get(srFieldName) != null){
                    //objCon.put(mapConSRField.get(srFieldName), step.getSObject('HexaBPM__SR__r').get(srFieldName));
                    objCon.put(mapConSRField.get(srFieldName), objSR.get(srFieldName));
                }
            }
            try{
                if(objCon.Id != null)
                {
                    if(objCon.Work_Permit_Validity__c != null && objCon.Employment_Type__c == 'Temporary Employee Work Permit' && objCon.Temporary_Work_Permit_Type__c == 'Seconded Employee')
                    {
                        if(objCon.Work_Permit_Validity_Count__c == null)
                            objCon.Work_Permit_Validity_Count__c = Integer.valueof(objCon.Work_Permit_Validity__c);
                        else
                            objCon.Work_Permit_Validity_Count__c = objCon.Work_Permit_Validity_Count__c  + Integer.valueof(objCon.Work_Permit_Validity__c);
                    }
                    update objCon; //update Contact details
                    system.debug('@@UPDATE OBJCON: ');
                    //creates a map for the field mapping for SR and Document Detail fields from the custom setting
                    Map<String, String> mapDocDetailSRField = new Map<String, String>();
                    Map<String, List<Document_Detail_SR_Field_Mapping__c>> mapDocDetailDocType = new Map<String, List<Document_Detail_SR_Field_Mapping__c>>();
                    
                    Set<String> documentTypes = new Set<String>();
                    for(Document_Detail_SR_Field_Mapping__c docDetailSRFieldMap : Document_Detail_SR_Field_Mapping__c.getAll().values()){
                        system.debug('------'+step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c+'-----'+docDetailSRFieldMap.Service_Request_Recordtype_API__c);
                        if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == docDetailSRFieldMap.Service_Request_Recordtype_API__c){
                            documentTypes.add(docDetailSRFieldMap.Document_Type__c);
                        }
                    }
                    system.debug('==contact id=='+objCon.Id+'======doc types=='+documentTypes);
                    List<Document_Details__c> docDetailList = new List<Document_Details__c>();
                    String docDetailsStr = queryAllDocumentDetailFields(objCon.Id,documentTypes);
                    docDetailList = Database.query(docDetailsStr);
                    system.debug('@@DOCDETAIL_LIST: '+docDetailList);
                    
                    for(Document_Details__c objDocDetail : docDetailList){
                        if(objDocDetail.Document_Type__c == 'Residence Visa'){ 
                            //objDocDetail.Document_Last_Renewed_Date__c = objDocDetail.Document_Issue_Date__c;
                            //objDocDetail.Document_Issue_Date__c = Date.Today();
                            objDocDetail.Document_Last_Renewed_Date__c = Date.Today();
                            objDocDetail.Document_Expiry_Date__c = Date.Today().addYears(3);
                            objDocDetail.Document_Status__c = 'Active';
                        } else if(objDocDetail.Document_Type__c == 'Temporary Employee Work Permit' ){
                            objDocDetail.Document_Issue_Date__c = Date.Today();
                            Integer permitDays = 0;
                            if(objSR.Work_Permit_Validity__c == '3'){
                                permitDays = 90;
                            } else if(objSR.Work_Permit_Validity__c == '6'){
                                permitDays = 180;
                            } else if(objSR.Work_Permit_Validity__c == '12'){
                                permitDays = 360;
                            }
                            objDocDetail.Document_Status__c = 'Active';
                            objDocDetail.Document_Expiry_Date__c = Date.Today().addDays(permitDays);
                        } else if(objDocDetail.Document_Type__c == 'Employee Work Permit(UAE/GCC National)'){
                            objDocDetail.Document_Issue_Date__c = Date.Today();
                            objDocDetail.Document_Expiry_Date__c = Date.Today().addYears(1);
                            objDocDetail.Document_Status__c = 'Active';
                        }
                        else if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Renew_Work_Permit_Full_Time_Non_Sponsored_Employee')
                        {
                            objDocDetail.Document_Last_Renewed_Date__c = Date.Today();
                            objDocDetail.Document_Expiry_Date__c = objCon.Work_Permit_Expiry_Date__c;
                            objDocDetail.Document_Status__c = 'Active';
                        }
                    }
                    
                    if(!docDetailList.isEmpty()){
                        update docDetailList;
                    }
                } else{
                    insert objCon; //insert contact details
                    
                    //creates a map for the field mapping for SR and Document Detail fields from the custom setting
                    Map<String, String> mapDocDetailSRField = new Map<String, String>();
                    Map<String, List<Document_Detail_SR_Field_Mapping__c>> mapDocDetailDocType = new Map<String, List<Document_Detail_SR_Field_Mapping__c>>();
                    
                    
                    for(Document_Detail_SR_Field_Mapping__c docDetailSRFieldMap : Document_Detail_SR_Field_Mapping__c.getAll().values()){
                        if(docDetailSRFieldMap.Service_Request_Recordtype_API__c == 'Dependent_Visa_Renewal'){
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
                    
                    //create Map for Document Detail recordtype
                    Map<String, Id> documentDetailRecTypeMap = new Map<String, Id>();
                    for(Recordtype rt : [SELECT Id, DeveloperName, Name FROM Recordtype WHERE SObjectType = 'Document_Details__c']){
                        documentDetailRecTypeMap.put(rt.Name, rt.Id);
                    }
                    System.debug('@@RECORDTYPE: '+documentDetailRecTypeMap);
                    List<Document_Details__c> docDetailToBeInserted = new List<Document_Details__c>();
                    
                    for(String key : mapDocDetailDocType.keyset()){
                        Document_Details__c objDocDetail = new Document_Details__c();
                        objDocDetail.Contact__c = objCon.Id;
                        objDocDetail.Account__c = objCon.AccountId;
                        objDocDetail.Document_Type__c = key;
                        if(documentDetailRecTypeMap.containskey(key)){
                            objDocDetail.RecordtypeId = documentDetailRecTypeMap.get(key);
                        }
                        objDocDetail.Document_Status__c = 'Active';
                        for(Document_Detail_SR_Field_Mapping__c ddSR : mapDocDetailDocType.get(key)){
                            objDocDetail.put(mapDocDetailSRField.get(ddSR.SR_Field_API_Name__c), objSR.get(ddSR.SR_Field_API_Name__c));
                        }
                        docDetailToBeInserted.add(objDocDetail);
                    }
                    system.debug('@@DOCDETAIL-LIST: '+docDetailToBeInserted);
                    insert docDetailToBeInserted;
                }  
            } catch(Exception e){
                system.debug('====exception ==='+e.getMessage());
                strResult = e.getMessage();
            }
        }
        return strResult;
    }
    
    global string queryAllContactFields(Id conId){
        String queryStr = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
           queryStr += ' ' + s + ', ';
        }
        queryStr = queryStr.subString(0,queryStr.Length()-2);
        queryStr += ' FROM Contact';
        queryStr += ' WHERE Id = \''+conId+'\'';
        
        return queryStr;
    }
    
    global string queryAllDocumentDetailFields(Id conId,set<string> documentTypes){
        String queryStr = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Document_Details__c').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
           queryStr += ' ' + s + ', ';
        }
        queryStr = queryStr.subString(0,queryStr.Length()-2);
        queryStr += ' FROM Document_Details__c';
        queryStr += ' WHERE Contact__c = \''+conId+'\'';
        queryStr += ' AND Document_Type__c IN :documentTypes';
        
        return queryStr;
    }
    
    global string queryAllSRFields(Id srId){
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
}