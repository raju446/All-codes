/*
    Author      : Durga Prasad
    Date        : 04-Jan-2018
    Description : Custom code to change the Employment Status to Absconded
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_UpdateEmployeeStatusOnAbsconding implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c stp) {
        string strResult = 'Success';
        if(stp!=null && stp.HexaBPM__SR__c!=null && stp.HexaBPM__SR__r.HexaBPM__Contact__c!=null){
            Contact objCon = new Contact(Id=stp.HexaBPM__SR__r.HexaBPM__Contact__c);
            list<Document_Details__c> lstDD = new list<Document_Details__c>();
            set<string> setDocumentTypes = new set<string>{'Employee Work Permit(UAE/GCC National)','Employee Work Permit','Entry Permit','Temporary Employee Work Permit','Residence Visa', 'Health Insurance' };
            for(Document_Details__c DD:[select Id,Document_Type__c,Document_Status__c from Document_Details__c where Contact__c=:stp.HexaBPM__SR__r.HexaBPM__Contact__c and Account__c=:stp.HexaBPM__SR__r.HexaBPM__Customer__c and Document_Type__c IN:setDocumentTypes]){
                if(stp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c=='Report_Absconding_Employee')
                    DD.Document_Status__c = 'Absconded';
                else if(stp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c=='Withdraw_Absconding_Status_Employee')
                    DD.Document_Status__c = 'Active';
                lstDD.add(DD);
            }
            if(stp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c=='Report_Absconding_Employee')
                objCon.Employment_Status__c = 'Absconded';
            else if(stp.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c=='Withdraw_Absconding_Status_Employee')
                objCon.Employment_Status__c = 'Active';
            try{
                update objCon;
                if(lstDD.size()>0)
                    update lstDD;
            }catch(Exception e){
                strResult = e.getMessage()+'';
            }
        }
        return strResult;
    }
}