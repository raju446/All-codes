/*
    Author      : Durga Prasad
    Company     : PwC
    Date        : 17-Sep-2017
    Description : class to check the Open SR of the same type and same customer exists
    -----------------------------------------------------------------------------------
*/
public without sharing class CheckOpenSR {
    public static string CheckOpenSRExists(HexaBPM__Service_Request__c objSR){
        string strResult = 'Success';
        if(objSR!=null && objSR.Id!=null && objSR.HexaBPM__Customer__c!=null && objSR.RecordTypeId!=null){
            if(objSR.HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c!='Letters' && objSR.HexaBPM__SR_Template__r.HexaBPM__Sub_menu__c!='Permits'){
                if(objSR.HexaBPM__Contact__c!=null && objSR.Dependent__c!=null){
                    for(HexaBPM__Service_Request__c OpenSR:[select Id,Name from HexaBPM__Service_Request__c where HexaBPM__Customer__c=:objSR.HexaBPM__Customer__c and RecordTypeId=:objSR.RecordTypeId and HexaBPM__Contact__c=:objSR.HexaBPM__Contact__c and Dependent__c=:objSR.Dependent__c and Id!=:objSR.Id and 
                    HexaBPM__IsClosedStatus__c=false and HexaBPM__IsCancelled__c=false and HexaBPM__Is_Rejected__c=false and HexaBPM__Internal_SR_Status__r.Name!='Draft']){
                        strResult = 'Duplicate Service Request ( '+OpenSR.Name+' ) found.';
                    }
                }else if(objSR.HexaBPM__Contact__c!=null && objSR.Dependent__c==null){
                    for(HexaBPM__Service_Request__c OpenSR:[select Id,Name from HexaBPM__Service_Request__c where HexaBPM__Customer__c=:objSR.HexaBPM__Customer__c and RecordTypeId=:objSR.RecordTypeId and HexaBPM__Contact__c=:objSR.HexaBPM__Contact__c and Passport_Issue_Date__c=:objSR.Passport_Issue_Date__c and Passport_Expiry_Date__c=:objSR.Passport_Expiry_Date__c and Country_of_Issue__c=:objSR.Country_of_Issue__c and Place_of_Issue__c=:objSR.Place_of_Issue__c and First_Name__c=:objSR.First_Name__c and Title__c=:objSR.Title__c and Middle_Name__c=:objSR.Middle_Name__c and Id!=:objSR.Id and 
                    HexaBPM__IsClosedStatus__c=false and HexaBPM__IsCancelled__c=false and HexaBPM__Is_Rejected__c=false and HexaBPM__Internal_SR_Status__r.Name!='Draft']){
                        strResult = 'Duplicate Service Request ( '+OpenSR.Name+' ) found.';
                    }
                }else if(objSR.P_O_Box_Type__c!=null && objSR.P_O_Box_Type__c!=''){
                    /*
                    for(HexaBPM__Service_Request__c OpenSR:[select Id,Name from HexaBPM__Service_Request__c where HexaBPM__Customer__c=:objSR.HexaBPM__Customer__c and RecordTypeId=:objSR.RecordTypeId and P_O_Box_Type__c=:objSR.P_O_Box_Type__c and Id!=:objSR.Id and HexaBPM__IsClosedStatus__c=false
                     and HexaBPM__IsCancelled__c=false and HexaBPM__Is_Rejected__c=false and HexaBPM__Internal_SR_Status__r.Name!='Draft']){
                        strResult = 'Duplicate Service Request ( '+OpenSR.Name+' ) found.';
                    }
                    */
                }else{
                    for(HexaBPM__Service_Request__c OpenSR:[select Id,Name from HexaBPM__Service_Request__c where HexaBPM__Customer__c=:objSR.HexaBPM__Customer__c and RecordTypeId=:objSR.RecordTypeId and Passport_Issue_Date__c=:objSR.Passport_Issue_Date__c and Passport_Expiry_Date__c=:objSR.Passport_Expiry_Date__c and Country_of_Issue__c=:objSR.Country_of_Issue__c and Place_of_Issue__c=:objSR.Place_of_Issue__c and First_Name__c=:objSR.First_Name__c and Title__c=:objSR.Title__c and Middle_Name__c=:objSR.Middle_Name__c and Id!=:objSR.Id and 
                    HexaBPM__IsClosedStatus__c=false and HexaBPM__IsCancelled__c=false and HexaBPM__Is_Rejected__c=false and HexaBPM__Internal_SR_Status__r.Name!='Draft']){
                        strResult = 'Duplicate Service Request ( '+OpenSR.Name+' ) found.';
                    }
                }
            }else if(objSR.HexaBPM__Record_Type_Name__c=='Permit_Alcohol' || objSR.HexaBPM__Record_Type_Name__c=='Permit_Shisha'){
                for(HexaBPM__Service_Request__c OpenSR:[select Id,Name from HexaBPM__Service_Request__c where HexaBPM__Customer__c=:objSR.HexaBPM__Customer__c and RecordTypeId=:objSR.RecordTypeId and Id!=:objSR.Id and HexaBPM__IsClosedStatus__c=false 
                and HexaBPM__IsCancelled__c=false and HexaBPM__Is_Rejected__c=false and HexaBPM__Internal_SR_Status__r.Name!='Draft']){
                    strResult = 'Duplicate Service Request ( '+OpenSR.Name+' ) found.';
                }
            }
        }
        return strResult;
    }
}