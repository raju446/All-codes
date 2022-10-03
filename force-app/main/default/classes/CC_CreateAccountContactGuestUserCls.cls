/*
    Author      : Kim Noceda
    Date        : 18-Sep-2017
    Description : Custom code to create Account and Contact records.
	--------------------------------------------------------------------------------------
    * @Change History
    * Author            Date            Description
    * Yogesh Mahajan	26jan2020		Added new webservice call
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_CreateAccountContactGuestUserCls implements HexaBPM.iCustomCodeExecutable {
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) {
        string strResult = 'Success';
        if(step.HexaBPM__SR__c!=null){
            //create Account record based on company name
            Account objAcct = new Account();
            if(step.HexaBPM__SR__r.Existing_Guest_User_Account_Id__c == null || step.HexaBPM__SR__r.Existing_Guest_User_Account_Id__c == ''){
                objAcct.Name = step.HexaBPM__SR__r.Company_Name__c;
                objAcct.Account_Name_Arabic__c = step.HexaBPM__SR__r.Company_Name_Arabic__c;
                objAcct.Email__c = step.HexaBPM__SR__r.HexaBPM__Email__c;
                objAcct.Entity_Id__c = step.HexaBPM__SR__r.License_Number__c;
                objAcct.HexaBPM__Portal_Balance__c =0;
                objAcct.OwnerId = Label.Business_Admin_User_Id;
                objAcct.Registered_for_Tax__c = step.HexaBPM__SR__r.Registered_for_Tax__c;
                objAcct.Tax_Registration_Number__c = step.HexaBPM__SR__r.Tax_Registration_Number__c;
                //objAcct.Registration_Link_Valid_Till__c = System.Now().addDays(180);
                if(System.Label.BM_Use_New_Entity_Oracle_Service == 'Yes' && System.Label.BM_Stop_Entity_Integration == 'No'){
                  /*  objAcct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ADGM_Guest').getRecordTypeId();
                    
                    //Add auto number to guest entity license number..
                    List<Guest_Running_Number__c> guestRefList = Guest_Running_Number__c.getall().values();
                    Guest_Running_Number__c guestRef = new Guest_Running_Number__c();
                    if(!guestRefList.isEmpty()){
                        guestRef = guestRefList[0];
                        guestRef.Running_Number__c = guestRef.Running_Number__c + 1;
                        update guestRef;
                    } else{
                        guestRef.Name = 'Guest';
                        guestRef.Running_Number__c = 1;
                        insert guestRef;
                    }
                    
                    if(guestRef != null) {
                        string rno = string.valueof(guestRef.Running_Number__c);
                        rno = rno.replaceAll('.0','');
                        objAcct.Guest_Auto_Number__c = Integer.valueof(rno);
                    } */
                }
            }
            
            //create Contact record under the account
            Contact objCon = new Contact();
            objCon.FirstName = step.HexaBPM__SR__r.First_Name__c;
            objCon.LastName = step.HexaBPM__SR__r.Last_Name__c;
            objCon.Email = step.HexaBPM__SR__r.HexaBPM__Email__c;
            objCon.MobilePhone = step.HexaBPM__SR__r.HexaBPM__Send_SMS_to_Mobile__c;
            //objCon.Community_Username__c = step.HexaBPM__SR__r.Guest_Username__c + '@adgm.portal';
            objCon.Community_Username__c = step.HexaBPM__SR__r.Guest_Username__c;
            objCon.Portal_User_Creation__c = true;
            objCon.Is_Guest_User__c = true;
            
            List<Recordtype> comUserConRtypeId = [SELECT Id FROM Recordtype WHERE SObjectType = 'Contact' AND DeveloperName = :Label.Community_User_Contact_Recordtype_Name LIMIT 1];
            objCon.RecordTypeId = comUserConRtypeId[0].Id;
            
            if(label.GuestUserValidityMonths!=null)
                objCon.User_Expiry_Date__c = system.today().addMonths(integer.valueof(label.GuestUserValidityMonths));
            else
                objCon.User_Expiry_Date__c = system.today().addMonths(6);
            try{
                if(step.HexaBPM__SR__r.Existing_Guest_User_Account_Id__c == null || step.HexaBPM__SR__r.Existing_Guest_User_Account_Id__c == ''){
                    //insert account and contact
                    //set account recordtype as ADGM Guest
                    Recordtype adgmGuest = [SELECT Id FROM Recordtype WHERE DeveloperName = :Label.ADGM_Guest_Account_Recordtype_API];
                    objAcct.RecordtypeId = adgmGuest.Id;
                    if(System.Label.BM_Use_New_Entity_Oracle_Service == 'Yes'){
                        objAcct.Oracle_Site_Id__c = '104';
                    }
                    
                    insert objAcct;
                    
                    //WS_Inf_GuestEntityCreationHelper.SendEntityToOraclde(objAcct.Id);
                    if(!Test.isRunningTest())
                        //WS_ERP_CreateGuestCustomerHelper.SendEntityToOracle(objAcct.Id);
                        ///* comments by yogesh on 26jan2020
                        //WS_Inf_CreateGuestEntityHelper.SendEntityToOracle(objAcct.Id);
                        // Added new Web service call
                        if(System.Label.BM_Stop_Entity_Integration == 'No'){
                            if(System.Label.BM_Use_New_Entity_Oracle_Service == 'Yes'){
                                EntityUtil.PushEntityToOracle_Future(new List<String>{objAcct.Id});
                            } else {
                                WS_ERP_CreateGuestCustomerHelper.SendEntityToOracle(objAcct.Id);
                            }
                        }
                        
                        
                    objCon.AccountId = objAcct.Id;
                    
                } else{
                    objCon.AccountId = step.HexaBPM__SR__r.Existing_Guest_User_Account_Id__c;
                }
                insert objCon;
                
            } catch(Exception e){
                strResult = e.getMessage();
                System.debug('##ERRORCLS: '+e.getmessage());
            }
        }
        return strResult;
    }
    
    
}