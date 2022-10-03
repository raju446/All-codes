/*
    Author      : Jayanta Karmakar
    Date        : 30-June-2019
    Description : Webservice class to create the Entity for billing management.
    --------------------------------------------------------------------------------------------
    Date        : 01-February-2020
    Description : Addition of new parameters in existing code.
*/
global class WS_CreateEntityService {
    webservice static ResponseDetails ProcessEntity(EntityInformation entityDetails) {
        system.debug(entityDetails);
        system.debug('The source system name is ---->' + entityDetails.SourceSystemName);
        ResponseDetails responseObj = new ResponseDetails();
        responseObj.EntityId = EntityDetails.EntityId;
        String MessageDetails = '';
        try{
            List<String> errorMsgs = new List<String>();
            if(entityDetails.EntityName == null || entityDetails.EntityName == ''){
                errorMsgs.add('EntityName can not be null / blank');    
            }
            /*if(entityDetails.EntityNameArabic == null || entityDetails.EntityNameArabic == ''){
                errorMsgs.add('EntityNameArabic can not be null / blank');   
            }*/
            if(entityDetails.EntityId == null || entityDetails.EntityId == ''){
                errorMsgs.add('EntityId can not be null / blank');   
            }
            if(entityDetails.EntityType == null || entityDetails.EntityType == ''){
                errorMsgs.add('EntityType can not be null / blank');   
            }
            if(entityDetails.SourceSystemName == null || entityDetails.SourceSystemName == ''){
                errorMsgs.add('SourceSystemName can not be null / blank');   
            }
            if(entityDetails.Address_Line1 == null || entityDetails.Address_Line1 == ''){
                errorMsgs.add('Address_Line1 can not be null / blank');   
            }
            if(entityDetails.Country == null || entityDetails.Country == ''){
                errorMsgs.add('country can not be null / blank');   
            }
            Id personContactRecId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Person_Contact').getRecordTypeId();
            if(errorMsgs.size() > 0){
                system.debug('===>'+ String.join(errorMsgs,',   '));
                responseObj.Success = false;
                MessageDetails = 'Please Review the below Error Messages :';
                MessageDetails += String.join(errorMsgs,',');   
                responseObj.Status_Code = '600';
            }else{
                Address__c addressObj = new Address__c();
                List<Account> accList = [Select id, (select id from Contacts where RecordtypeId = : personContactRecId ) from Account where Source_System_Id__c =: EntityDetails.EntityId AND Recordtype.Developername =: entityDetails.Recordtype_DeveloperName LIMIT 1];
                system.debug(accList);
                String operation = 'created';
                Account accObj = new Account();
                if(accList.size() > 0){
                    accObj.Id = accList[0].id;
                    operation = 'updated';
                }else{
                    accObj.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(entityDetails.Recordtype_DeveloperName).getRecordTypeId();
                }
                accObj.Name = EntityDetails.EntityName;
                //accObj.Entity_Id__c = EntityDetails.EntityId;
                accObj.Source_System_Id__c = EntityDetails.EntityId;
                accObj.Account_Name_Arabic__c = EntityDetails.EntityNameArabic;
                accObj.Entity_Type__c = EntityDetails.EntityType;
                accObj.Source_System_Name__c = entityDetails.SourceSystemName;
                accObj.Entity_Sub_Type__c = entityDetails.Entity_Sub_Type;
                accObj.Category__c = entityDetails.Entity_License_Category;
                if(entityDetails.Expiry_Date != null && entityDetails.Expiry_Date != ''){
                    List<String> expDate = entityDetails.Expiry_Date.split('/');
                    accObj.License_Expiry_Date__c = date.newinstance(Integer.valueOf(expDate[2]), Integer.valueOf(expDate[1]), Integer.valueOf(expDate[0]));
                }
                if(entityDetails.Registration_Date != null && entityDetails.Registration_Date != ''){
                    List<String> regDate = entityDetails.Registration_Date.split('/');
                    accObj.Registration_Date__c = date.newinstance(Integer.valueOf(regDate[2]), Integer.valueOf(regDate[1]), Integer.valueOf(regDate[0]));
                }
                
                accObj.Entity_Status__c = entityDetails.Registration_Status;
                accObj.Commercial_License__c = entityDetails.Commercial_License;
                accObj.Tax_Registration_Number__c = entityDetails.VAT_REG_NO;
                if(entityDetails.Recordtype_DeveloperName == 'ADGM_Guest'){
                    accObj.billingstreet = entityDetails.Address_Line1 +', '+ entityDetails.Address_Line2+', '+ entityDetails.Address_Line3+', '+ entityDetails.Address_Line4+','+entityDetails.Province;
                    accObj.billingcity = entityDetails.City;
                    accObj.billingstate = entityDetails.State;
                    accObj.billingcountry= entityDetails.Country;
                    accObj.billingpostalcode = entityDetails.Postal_Code;
                  //  accObj.Billing_County__c = entityDetails.County;
                } else {
                    addressObj.Building_Name__c = entityDetails.Address_Line3 + ', '+ entityDetails.Address_Line4;
                    addressObj.Floor__c = entityDetails.Address_Line2;
                    addressObj.Office_Number__c = entityDetails.Address_Line1;
                    addressObj.POBoxNumber__c = entityDetails.Postal_Code;
                    addressObj.State__c = entityDetails.State +'/ '+entityDetails.Province;
                    addressObj.Country__c = entityDetails.Country;
                    addressObj.Emirates__c = entityDetails.City;
                    addressObj.County__c = entityDetails.County;
                    addressObj.Type__c = 'Physical';
                }
                Contact objPersonContact = new contact();
                
                upsert accObj;
                
                if(entityDetails.PersonFirstName <> null && entityDetails.PersonFirstName <> '' && entityDetails.PersonLastName <> null && entityDetails.PersonLastName <> '') {
                    String entityPersonName = entityDetails.PersonFirstName +' '+entityDetails.PersonLastName;
                    if(EntityDetails.EntityName == entityPersonName ) {
                        if(accList<>null && accList.size() > 0 && accList[0].contacts <> null && accList[0].contacts.size() > 0)
                            objPersonContact.id = accList[0].contacts[0].id;
                        objPersonContact.recordtypeid = personContactRecId;
                        objPersonContact.FirstName = entityDetails.PersonFirstName;
                        objPersonContact.LastName = entityDetails.PersonLastName;
                        objPersonContact.Country__c = entityDetails.Country;
                        objPersonContact.State_Province__c = entityDetails.State +((!String.isEmpty(entityDetails.Province)?'/ '+entityDetails.Province:''));
                        objPersonContact.City__c = entityDetails.City;
                        objPersonContact.Street__c = entityDetails.Address_Line1 +', '+entityDetails.Address_Line2+', '+entityDetails.Address_Line3+ ', '+ entityDetails.Address_Line4;
                        if(accObj.id <> null)
                            objPersonContact.AccountId = accObj.id;
                        upsert objPersonContact;
                    }
                    
                }
                

                if(entityDetails.Recordtype_DeveloperName != 'ADGM_Guest'){
                    String buildingName = entityDetails.Address_Line3 + ', '+ entityDetails.Address_Line4;
                    list<Address__c> addresses = [SELECT ID from Address__c where Building_Name__c =: buildingName AND Floor__c=: entityDetails.Address_Line2 AND 
                                                  Office_Number__c=: entityDetails.Address_Line1 AND POBoxNumber__c =: entityDetails.Postal_Code AND State__c =: entityDetails.State AND
                                                  Country__c = : entityDetails.County AND Emirates__c =: entityDetails.City AND Entity__c =: accObj.id];

                    if(addresses.size() == 0){
                        addressObj.Entity__c = accObj.id;
                        insert addressObj;
                    }
                }
                
                List<Account> accLst = [SELECT id,Oracle_Party_Id__c from Account WHERE Id =: accObj.Id];
                if(accLst!=null && accLst.size() > 0){
                    if(accLst[0].Oracle_Party_Id__c == null && !system.test.isrunningtest())
                        EntityUtil.PushEntityToOracle_Future(new List<String>{accLst[0].Id}); 
                } 
                
                responseObj.EntityId = EntityDetails.EntityId;
                responseObj.SF_EntityID = accObj.id;
                responseObj.Success = true;
                responseObj.Status_Code = '200';
                MessageDetails = 'Entity '+operation+' successfully!';  
                responseObj.Messages = MessageDetails;
                System.debug('------------------>'+responseObj);
            }
        }catch(Exception e){
            responseObj.EntityId = EntityDetails.EntityId;
            responseObj.Success = false;
            responseObj.Status_Code = '600';
            String errMsg = 'Please Review the below Error Messages :'+ e.getMessage();
            responseObj.Messages = errMsg;
           // return responseObj;
        }
        
        return responseObj;
    }
    
    global class ResponseDetails{
        webservice string SF_EntityId;
        webservice string EntityId;
        webservice boolean Success;
        webservice string Messages; 
        webservice string Status_Code;
    }
    
    global class EntityInformation{
        webservice string Recordtype_DeveloperName; 
        webservice string EntityName;
        webservice string EntityNameArabic;
        webservice string EntityId;
        webservice string EntityType;
        webservice string SourceSystemName;
        webservice string Entity_License_Category; //salesforce field missing
        webservice string Entity_Sub_Type;
        webservice string Expiry_Date;
        webservice string Registration_Date;
        webservice string Registration_Status;
        webservice string Commercial_License;
        webservice string VAT_REG_NO; // salesforce field missing
        webservice string Address_Line1;
        webservice string Address_Line2;
        webservice string Address_Line3;
        webservice string Address_Line4;
        webservice string City;
        webservice string State;
        webservice string Country;
        webservice string Province;
        webservice string Postal_Code;
        webservice string County;
        webservice string PersonFirstName;
        webservice string PersonLastName;
    }
}