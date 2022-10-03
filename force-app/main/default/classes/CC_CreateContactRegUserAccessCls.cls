/*
    Author      : Kim Noceda
    Date        : 14-Dec-2017
    Description : Custom code to create Contact Records for User Access Request for Registered Company.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_CreateContactRegUserAccessCls implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        string PortalAdminProfileId;
        if (step.HexaBPM__SR__c != null) {
            list<User> lstPortalUser = [select id,contactId, username, Types_of_Services_Accessible__c,IsActive from User where username = :step.HexaBPM__SR__r.Guest_Username__c  limit 1];
            if(lstPortalUser != null && !lstPortalUser.IsEmpty()){
                //Update User and Contact Record with the accessible services.
                try{
                    Contact contact = new Contact(Id = lstPortalUser[0].contactId);
                    contact.Types_of_Services_Accessible__c = step.HexaBPM__SR__r.Types_of_Services_Accessible__c;
                    contact.Role__c = step.HexaBPM__SR__r.Role__c;
                    update contact;
                    updateUserRoles(lstPortalUser[0].id,contact.Types_of_Services_Accessible__c,contact.Role__c,lstPortalUser[0].IsActive);
                }catch (Exception e) {
                    strResult = e.getMessage();
                }
            }else{
                //create Contact record under the account
                Contact objCon = new Contact();
                objCon.FirstName = step.HexaBPM__SR__r.First_Name__c;
                objCon.LastName = step.HexaBPM__SR__r.Last_Name__c;
                objCon.Email = step.HexaBPM__SR__r.HexaBPM__Email__c;
                objCon.MobilePhone = step.HexaBPM__SR__r.HexaBPM__Send_SMS_to_Mobile__c;
                objCon.Community_Username__c = step.HexaBPM__SR__r.Guest_Username__c;
                objCon.Portal_User_Creation__c = true;
                objCon.Is_Guest_User__c = false;
                objCon.AccountId = step.HexaBPM__SR__r.HexaBPM__Customer__c;
                objCon.Role__c = step.HexaBPM__SR__r.Role__c;
                objCon.Types_of_Services_Accessible__c = step.HexaBPM__SR__r.Types_of_Services_Accessible__c;
                if(step.HexaBPM__SR__r.HexaBPM__Customer__c!=null && step.HexaBPM__SR__r.Role__c=='Lead Admin'){
                    for(User usr:[Select Id from User where Contact.AccountId=:step.HexaBPM__SR__r.HexaBPM__Customer__c and IsActive=true and Contact.Role__c='Lead Admin' limit 1]){
                        objCon.Role__c = 'Admin';
                    }
                }
                if(step.HexaBPM__SR__r.Sponsored_Employee__c == 'Yes') {
                    objCon.Sponsored_Employee__c = true;
                }

                List < Recordtype > comUserConRtypeId = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact'
                    AND DeveloperName =: Label.Community_User_Contact_Recordtype_Name LIMIT 1
                ];
                objCon.RecordTypeId = comUserConRtypeId[0].Id;

                Account objAcct = [SELECT Id, Portal_Lead_Admin__c, Tax_Registration_Number__c, Entity_Type__c, Entity_Sub_Type__c FROM Account WHERE Id =: objCon.AccountId LIMIT 1];

                Set < String > entityTypeSet = new Set < String > ();
                if (!Label.Company_User_Type_Assign_Guest.contains(';')) {
                    entityTypeSet.add(Label.Company_User_Type_Assign_Guest);
                } else {
                    for (String str: Label.Company_User_Type_Assign_Guest.split(';')) {
                        entityTypeSet.add(str);
                    }
                }
                Set < String > entitySubTypeSet = new Set < String > ();
                if (!Label.Company_User_SubType_Assign_Guest.contains(';')) {
                    entitySubTypeSet.add(Label.Company_User_SubType_Assign_Guest);
                } else {
                    for (String str: Label.Company_User_SubType_Assign_Guest.split(';')) {
                        entitySubTypeSet.add(str);
                    }
                }

                if (entityTypeSet.contains(objAcct.Entity_Type__c)) {
                    objCon.Is_Guest_User__c = true;
                } else {
                    if (entitySubTypeSet.contains(objAcct.Entity_Sub_Type__c)) {
                        objCon.Is_Guest_User__c = true;
                    }
                }

                try {
                    insert objCon;

                    objAcct.Registered_for_Tax__c = step.HexaBPM__SR__r.Registered_for_Tax__c;
                    objAcct.Tax_Registration_Number__c = step.HexaBPM__SR__r.Tax_Registration_Number__c;
                    objAcct.Portal_Lead_Admin__c = objCon.Id;
                    update objAcct;

                } catch (Exception e) {
                    strResult = e.getMessage();
                }
            }
        }
        return strResult;
    }
    @future
    public static void updateUserRoles(string UserId,string AccessType,string role, boolean isActiveUser){
    	string PortalAdminProfileId;
    	User portalUser = new User(Id=UserId);
        if(isActiveUser == false)
            portalUser.isActive = true;
        for(Profile pf:[SELECT Id, Name FROM Profile WHERE Name = :Label.Community_Profile_Name LIMIT 1]){
        	PortalAdminProfileId = pf.Id;
        }
        portalUser.Role__c = role;
    	if(PortalAdminProfileId!=null && AccessType!=null && AccessType.indexOf('Company Services')>-1 && AccessType.indexOf('Payment - Account Services')>-1 && AccessType.indexOf('Permits Services')>-1 && AccessType.indexOf('Visa & Letter Services')>-1){
            portalUser.ProfileId = PortalAdminProfileId;
        }else{
        	if(AccessType!=null && AccessType.indexOf('Payment - Account Services')>-1)
        		portalUser.ProfileId = label.OSS_Community_Login_User_Payment;
        	else
        		portalUser.ProfileId = label.OSS_Community_Login_User;
        }
        portalUser.Types_of_Services_Accessible__c = AccessType;
        update portalUser;
        
    	list<PermissionSetAssignment> lstPSA = new list<PermissionSetAssignment>();
        map<string,string> MapPermissionSets = new map<string,string>();
        for(PermissionSet PS:[SELECT Id,Label,Name,License.Name FROM PermissionSet where License.Name='Customer Community Login']){
        	if(PS.Label.StartsWith('00e')==false)
        		MapPermissionSets.put(PS.Label,PS.Id);
        }
        list<PermissionSetAssignment> lstPSATBD = new list<PermissionSetAssignment>();
        lstPSATBD = [Select Id from PermissionSetAssignment where AssigneeId=:portalUser.Id and PermissionSetId IN:MapPermissionSets.values()];
        if(lstPSATBD.size()>0)
        	delete lstPSATBD;
		for(string PermissionSetName : MapPermissionSets.keyset()){
			if(portalUser.Types_of_Services_Accessible__c!=null && portalUser.Types_of_Services_Accessible__c.indexOf(PermissionSetName)>-1){
				PermissionSetAssignment PSA = new PermissionSetAssignment(PermissionSetId=MapPermissionSets.get(PermissionSetName),AssigneeId=portalUser.Id);
				lstPSA.add(PSA);
			}
		}
        if(lstPSA.size()>0)
        	upsert lstPSA;
    }

}