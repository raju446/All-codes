/*
    Author      : Kim Noceda
    Date        : 06-Sep-2017
    Description : Custom code to create Contact records based on the mapping.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_CreateContactCls implements HexaBPM.iCustomCodeExecutable { 
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        system.debug('========');
         if(step.HexaBPM__SR__c!=null)
         {
            String querySRStr                   = queryAllSRFields(step.HexaBPM__SR__c);
            HexaBPM__Service_Request__c objSR   = Database.query(querySRStr);
            Map<String, String> mapConSRField   = new Map<String, String>();
            Contact objCon = new Contact();
            
            //iterate on the custom setting for the field mapping
            for(Contact_SR_Field_Mapping__c cSRFieldMap : Contact_SR_Field_Mapping__c.getAll().values()){
                if(cSRFieldMap.Active__c == TRUE){
                    mapConSRField.put(cSRFieldMap.SR_Field_API_Name__c, cSRFieldMap.Contact_Field_API_Name__c);
                }
            }
            
            system.debug('@@CREATECON');
            System.debug('@@MAPFIELDS: '+mapConSRField);
            
            //iterate on the field mapping map to put the values to the new contact record
            for(String srFieldName : mapConSRField.keyset()){
                objCon.put(mapConSRField.get(srFieldName), objSR.get(srFieldName));
            }
            System.debug('@@OBJCON: '+objCon);
            
            String rectypeAPI = '';
            if(step.HexaBPM__SR__r.Sub_Menu__c == 'Employee' || step.HexaBPM__SR__r.Sub_Menu__c == 'Work Permits')
            {
                rectypeAPI = 'Contact_Employee';
                objCon.Employment_Status__c = 'Active';
                if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Employment_Visa_New' || step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Visa_Transfer'){
                    objCon.Employment_Type__c = 'Employee Work Permit';
                }
                else if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Long_Term_Residence_Visa_New'){
                    objCon.Employment_Type__c = 'Long Term Visa Holder';
                }
                else if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'New_Work_Permit_Full_Time_Non_Sponsored_Employee'){
                    objCon.Employment_Type__c = 'Full Time Non Sponsored Employee   ';
                }
                else if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Employee_Work_Permit_UAE_GCC_National_New'){
                    objCon.Employment_Type__c = 'Employee Work Permit(UAE/GCC National)';
                } 
                else if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Temporary_Work_Permit_New')
                {
                    objCon.Employment_Type__c = 'Temporary Employee Work Permit';
                    if(objCon.Work_Permit_Validity__c != null)
                    objCon.Work_Permit_Validity_Count__c = Integer.valueof(objCon.Work_Permit_Validity__c);
                }
            } 
            else if(step.HexaBPM__SR__r.Sub_Menu__c == 'Dependent')
            {
                rectypeAPI                  = 'Contact_Dependent';
                objCon.Dependent_Status__c  = 'Active';
                objCon.Sponsor__c           = step.HexaBPM__SR__r.HexaBPM__Contact__c;
            }
            List<Recordtype> rectype = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = :rectypeAPI LIMIT 1];
            if(!rectype.isEmpty()){
                objCon.RecordtypeId = rectype[0].Id;
            }
            
            
            //insert new contact record
            try{
                List<Contact> contacts = [Select Id FROM Contact Where Passport_No__c=:objSR.Passport_Number__c and AccountId=:objSR.HexaBPM__Customer__c LIMIT 1];
                if(!contacts.isEmpty()){
                    objCon.id = contacts[0].id;
                    update objCon;
                }else{
                    insert objCon;
                }
                
                //creates a map for the field mapping for SR and Document Detail fields from the custom setting
                Map<String, String> mapDocDetailSRField = new Map<String, String>();
                Map<String, List<Document_Detail_SR_Field_Mapping__c>> mapDocDetailDocType = new Map<String, List<Document_Detail_SR_Field_Mapping__c>>();
                
                
                for(Document_Detail_SR_Field_Mapping__c docDetailSRFieldMap : Document_Detail_SR_Field_Mapping__c.getAll().values()){
                    if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == docDetailSRFieldMap.Service_Request_Recordtype_API__c){
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
                        //objDocDetail.put(mapDocDetailSRField.get(ddSR.SR_Field_API_Name__c), step.getSObject('HexaBPM__SR__r').get(ddSR.SR_Field_API_Name__c));
                        objDocDetail.put(mapDocDetailSRField.get(ddSR.SR_Field_API_Name__c), objSR.get(ddSR.SR_Field_API_Name__c));
                        /*for(String srFieldName : mapDocDetailSRField.keyset()){
                            objDocDetail.put(mapDocDetailSRField.get(srFieldName), step.getSObject('HexaBPM__SR__r').get(srFieldName));
                            System.debug('##FIELDNAME: '+mapDocDetailSRField.get(srFieldName));
                            
                        }*/
                    }
                    docDetailToBeInserted.add(objDocDetail);
                }
                system.debug('@@DOCDETAIL-LIST: '+docDetailToBeInserted);
                insert docDetailToBeInserted;
                
                if(rectypeAPI == 'Contact_Employee'){
                    objSR.HexaBPM__Contact__c = objCon.Id;
                    update objSR;
                }
                
            } catch(Exception e){
                strResult = e.getMessage();
            }
        }
        /*if(step.HexaBPM__SR__c!=null && step.HexaBPM__SR__r.Last_Name__c!=null){
            Contact objCon = new Contact();
            objCon.AccountId = step.HexaBPM__SR__r.HexaBPM__Customer__c;
            objCon.LastName = step.HexaBPM__SR__r.Last_Name__c;
            try{
                insert objCon;
            }catch(Exception e){
                strResult = e.getMessage();
            }
        }*/
        return strResult;
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