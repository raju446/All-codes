global without sharing class ParticipantRequired{

    webservice static string srParticipantValidation(string sRequestId){
        HexaBPM__Service_Request__c srNumber = [SELECT Id, Service_Request_Name__c,Type_of_Entertainment__c, Speaker_present__c, 
                                                Number_of_Participants__c, HexaBPM__FinalizeAmendmentFlg__c 
                                                FROM HexaBPM__Service_Request__c
                                                WHERE Id = :sRequestId];
                                                
        if(srNumber.Service_Request_Name__c  == 'Trainings and Seminars Permit' ||
            srNumber.Service_Request_Name__c  == 'Photography Permit' ||
            srNumber.Service_Request_Name__c  == 'Entertainment Permit' || 
            srNumber.Service_Request_Name__c  == 'Extended Business Hours Permit'){
            if(srNumber.Number_of_Participants__c < 1){
                return 'Failed';
            }
        } else if(srNumber.Service_Request_Name__c  == 'Events and Exhibition Permit' &&
                (srNumber.Type_of_Entertainment__c != 'None'  ||
                srNumber.Speaker_present__c == 'Yes')){
            if(srNumber.Number_of_Participants__c < 1){
                return 'Failed';
            }
        }
        
        return 'Success';
    }
    
    webservice static string EmpimageValidation(string sRequestId)
    {
        HexaBPM__Service_Request__c srNumber = [SELECT Id, Employee_Picture__c,Service_Request_Name__c,HexaBPM__Record_Type_Name__c                                               
                                                FROM HexaBPM__Service_Request__c
                                                WHERE Id = :sRequestId];
        //set<string> SRNames = new set<string>();
        //SRNames.add('WP_Female_Under_Father_Or_Husband_Sponsorship_New');
                                     
        if((srNumber.Employee_Picture__c == null || srNumber.Employee_Picture__c == '')
            && (
                   srNumber.Service_Request_Name__c == 'Employment Visa - New' 
                || srNumber.Service_Request_Name__c == 'Temporary Work Permit - New'
                || srNumber.Service_Request_Name__c == 'Employee Work Permit (UAE/GCC National) - New'
                || srNumber.Service_Request_Name__c == 'Employee Work Permit (UAE/GCC National) - Renew'
                || srNumber.Service_Request_Name__c == 'Employment Residence Visa - Renewal' 
                || srNumber.Service_Request_Name__c == 'New Work Permit for ADGM Sponsored Employees'
                || srNumber.HexaBPM__Record_Type_Name__c == 'New_Work_Permit_Full_Time_Non_Sponsored_Employee'
                || srNumber.HexaBPM__Record_Type_Name__c == 'Renew_Work_Permit_Full_Time_Non_Sponsored_Employee'
                || srNumber.HexaBPM__Record_Type_Name__c == 'Temporary_Work_Permit_Renew'
                || srNumber.HexaBPM__Record_Type_Name__c == 'Visa_Transfer'
                || srNumber.HexaBPM__Record_Type_Name__c == 'Long_Term_Residence_Visa_New'
               )
            )
            return 'true';
        return 'false';
    }
}