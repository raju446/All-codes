/*
    Author      : Kim Noceda
    Date        : 11-Apr-2018
    Description : Trigger handler class that is being referenced in the RoleTriggerHandler.
                  All DML methods are being handled in this handler class.
    --------------------------------------------------------------------------------------
*/
public without sharing class RoleTriggerHelper {
    /*
        Method Name :   InitiateCIDApproval
        Description :   Method to Initiate CID Approval for the Entity.
    */
    public static void InitiateCIDApproval(List<Role__c> roleList, Map<Id, Role__c> oldRoleMap, Boolean isInsert)
    {
        List<HexaBPM__Service_Request__c> objSRList = new List<HexaBPM__Service_Request__c>();
        Id cidRectypeId;
        List<User> currentUser = [SELECT Id, UserType, Email FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
        if(!currentUser.isEmpty())
        {
            if(currentUser[0].UserType == 'Standard')
            {
                for(RecordType rectype : [SELECT Id from RecordType WHERE sObjectType='HexaBPM__Service_Request__c' AND DeveloperName=:Label.Initial_Approval_Recordtype_API AND IsActive=true LIMIT 1]){
                   cidRectypeId = rectype.Id;
                }
                
                Set<Id> accountIds = new Set<Id>();
                for(Role__c objRole : roleList)
                {
                    if(isInsert == true){
                        accountIds.add(objRole.Subject_Account__c);
                    } 
                    else
                    {
                        if(
                        	//(objRole.Capacity__c != oldRoleMap.get(objRole.Id).Capacity__c) ||
                            //(objRole.Country_of_Residence__c != oldRoleMap.get(objRole.Id).Country_of_Residence__c) ||
                            (objRole.Forenames__c != oldRoleMap.get(objRole.Id).Forenames__c) ||
                            //(objRole.Forenames_in_Arabic__c != oldRoleMap.get(objRole.Id).Forenames_in_Arabic__c) ||
                            (objRole.Nationality__c != oldRoleMap.get(objRole.Id).Nationality__c) ||
                            //(objRole.Passport_Number__c != oldRoleMap.get(objRole.Id).Passport_Number__c) ||
                            //(objRole.Status__c != oldRoleMap.get(objRole.Id).Status__c) ||
                            (objRole.Surname__c != oldRoleMap.get(objRole.Id).Surname__c))
                            //(objRole.Surname_in_Arabic__c != oldRoleMap.get(objRole.Id).Surname_in_Arabic__c) ||
                            //(objRole.Role_Name__c != oldRoleMap.get(objRole.Id).Role_Name__c))
                        {
                            accountIds.add(objRole.Subject_Account__c);
                        }
                    }
                }
                
                for(Account objAcct : [SELECT Id, License_Expiry_Date__c, Entity_Id__c,Is_Initial_Approval__c,TotalAuthorisedSignatories__c, 
                                        (SELECT Id FROM Relationships__r WHERE Status__c = 'Active' AND Type__c = 'Authorised Signatory' ),
                                        (SELECT Id from Business_Activities__r LIMIT 1)
                                        FROM Account WHERE Id IN :accountIds])
                {
                    if(objAcct.Is_Initial_Approval__c == false)
                    {
	                    if(objAcct.Business_Activities__r.size() > 0 && objAcct.License_Expiry_Date__c != null )
	                    {
	                            HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
	                            objSR.License_Number__c = objAcct.Entity_Id__c;
	                            objSR.RecordtypeId = cidRectypeId;
	                            objSR.HexaBPM__Customer__c = objAcct.Id;
	                            objSR.HexaBPM__Email__c = currentUser[0].Email;
	                            objSR.HexaBPM__Auto_Submit__c = true;
	                            objSRList.add(objSR);
	                    }
                    }
                }
		        
		        if(!objSRList.isEmpty()){
                    Savepoint sp = Database.setSavepoint();
                    try{
                        insert objSRList;
                    } catch(Exception e){
                        System.debug('##Error: '+e.getMessage());
                        Database.rollback(sp);
                    }
                }
            }
        }
    }
}