global without sharing class ICA_ValidateService 
{
    webservice static string validateRoles(Id accid, Id srid)
    {
        string message='';
        if(accid != null)
        {
            /*list<HexaBPM__Service_Request__c> openSrs = new list<HexaBPM__Service_Request__c>();
            openSrs = [Select id FROM HexaBPM__Service_Request__c WHERE HexaBPM__Customer__c=:accid and HexaBPM__External_Status_Name__c = 'Awaiting Approval' and ID !=:];
            if(!openSrs.isEmpty()){
                message += ' There are open Initial Approval SRs, kindly close them before submitting a new request.';
                return message;
            }*/
            list<HexaBPM__Service_Request__c> checkReqFields = [Select Recordtype.Developername, establishmentRequestActionTypeId__c, Establishment_Request_Type__c, Establishment_Partnership_Type__c, 
                    Initial_Approval_Number__c,HexaBPM__Customer__c, HexaBPM__Submitted_Date__c FROM HexaBPM__Service_Request__c WHERE Id=:srid];
            if(!checkReqFields.isEmpty())
            {
                if(checkReqFields[0].Recordtype.Developername == 'Initial_Approval' &&  (checkReqFields[0].establishmentRequestActionTypeId__c == null || checkReqFields[0].Establishment_Request_Type__c == null || checkReqFields[0].Establishment_Partnership_Type__c == null)){
                    message += 'Please make sure that Establishment Request Action Type, Establishment Request Type and Establsihment Partnership Type are not blank.\n';
                }
                else if(checkReqFields[0].Recordtype.Developername == 'Establishment_Card_New')
                {
                    if(checkReqFields[0].Initial_Approval_Number__c == null)
                    {
                        list<Account> acc = [Select id, Initial_Approval_Issue_Date__c FROM Account where id=:checkReqFields[0].HexaBPM__Customer__c and Initial_Approval_Issue_Date__c != null];
                        if(!acc.isEmpty() && checkReqFields[0].HexaBPM__Submitted_Date__c != null 
                            && (acc[0].Initial_Approval_Issue_Date__c.daysBetween(checkReqFields[0].HexaBPM__Submitted_Date__c) <90)){
                            message += 'Initial Approval Number is mandarory. \n';
                        }
                    }
                    list<Address__c> address = [SELECT Building_Name__c, Office_Number__c, Address_for_DDP__c FROM Address__c WHERE Entity__c=:accid and Type__c='Physical' LIMIT 1];
                    if(address.isEmpty()){
                        message += 'Address details not found under the entity. \n';
                    }else{
                        if(address[0].Building_Name__c == null){
                            message += 'Address: Building name is blank. \n';
                        }
                        if(address[0].Office_Number__c == null){
                            message += 'Address: Office Number is blank. \n';
                        }  
                    }
                }
            }
            list<Role__c> roles =  [SELECT Unified_ID__c, Role_Full_Name__c, Role_Full_Name_Arabic__c, Nationality__c FROM Role__c 
                    WHERE Subject_Account__c=:accid and Status__c='Active' Order by LastModifiedDate DESC];
            if(roles.isEmpty()){
                message += 'There are no authorised Signatories. \n';
            }
            for(Role__c r : roles)
            {
                if(r.Unified_ID__c == null){
                    message += 'Unified ID of ' +r.Role_Full_Name__c + ' should not be blank. \n';
                }
                if(r.Role_Full_Name_Arabic__c == null){
                    message += ' Arabic name of '+r.Role_Full_Name__c + ' Should not be blank. \n';
                }
                if(r.Nationality__c == null){
                    message += 'Nationality of '+r.Role_Full_Name__c + ' Should not be blank \n';
                }
            }
        }
        return message;
    }
}