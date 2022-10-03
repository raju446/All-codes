/*
    Author      : Durga Prasad
    Date        : 30-April-2018
    Description : Webservice class to create the Catalyst Entity and its Childs on CID Approval
    Version History :
    v1.0     Durga Prasad    22-Nov-2019    Changed the Activity Name mapping to Description fields because of field size issue.
    v2.0  Azmath  16-April-2020  Modified the entity updated logic from upsert to insert/update.
    --------------------------------------------------------------------------------------------
*/
global without sharing class WS_CreateCatalystEntity{
    webservice static ResponseDetails ProcessEntity(EntityInformation EntityDetails) {
        ResponseDetails objResp = new ResponseDetails();
        objResp.Success = true;
        objResp.Message = 'Entity processed successfully.';
        objResp.EntityId = EntityDetails.EntityId;
        objResp.StatusCode = '200';

        ResponseDetails objErrorResponse = new ResponseDetails();
        objErrorResponse.SF_Entity_ID = 'Null';
        objErrorResponse.EntityId = EntityDetails.EntityId;
        objErrorResponse.StatusCode = '600';
        objErrorResponse.Success = false;
      
        if(EntityDetails.BusinessActivities==null || (EntityDetails.BusinessActivities!=null && EntityDetails.BusinessActivities.size()==0)){
            objErrorResponse.Message = 'Error: Atleast one Business Activity is required.';
            return objErrorResponse;
        }
        if(EntityDetails.PhysicalAddress==null || (EntityDetails.PhysicalAddress!=null && (EntityDetails.PhysicalAddress.BuildingName=='' || EntityDetails.PhysicalAddress.BuildingName==null))){
            objErrorResponse.Message = 'Error: Physical Address is required.';
            return objErrorResponse;
        }
        if(EntityDetails.PostalAddress==null || (EntityDetails.PostalAddress!=null && EntityDetails.PostalAddress.Country=='')){
            objErrorResponse.Message = 'Error: Postal Address is required.';
            return objErrorResponse;
        }
        
        /* CR051 DROP 2 CHANGES START ...*/
        if(EntityDetails.IsCIDApproval == false && (EntityDetails.RegistrationDate == null || EntityDetails.RegistrationDate == '' || EntityDetails.RegistrationDate == 'null'))
        {
            objErrorResponse.Message = 'Error: Registration Date is required.';
            return objErrorResponse;
        }
        if(EntityDetails.IsCIDApproval == false && (EntityDetails.ExpiryDate == null || EntityDetails.ExpiryDate == '' || EntityDetails.ExpiryDate == 'null'))
        {
            objErrorResponse.Message = 'Error: Expiry Date is required.';
            return objErrorResponse;
        }
        
        /* CR051 END ...*/
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADGM Registered Company').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeid = accRecordTypeId;
        acc.Name = EntityDetails.EntityName;
        acc.Entity_Id__c = EntityDetails.EntityId;
        if(EntityDetails.EntityNameArabic!=null)
            acc.Account_Name_Arabic__c = EntityDetails.EntityNameArabic;
        if(EntityDetails.RegistrationDate!=null && EntityDetails.RegistrationDate != '' &&  EntityDetails.RegistrationDate != 'null')
        {
            acc.Registration_Date__c = Date.valueOf(EntityDetails.RegistrationDate);
        }
        if(EntityDetails.ExpiryDate!=null && EntityDetails.ExpiryDate != '' && EntityDetails.ExpiryDate != 'null')
        {
            acc.License_Expiry_Date__c = Date.valueOf(EntityDetails.ExpiryDate);
        }
        if(EntityDetails.RegistrationStatus!=null )
            acc.Entity_Status__c = EntityDetails.RegistrationStatus;
        if(EntityDetails.EntityType!=null)
            acc.Entity_Type__c = EntityDetails.EntityType;
        if(EntityDetails.EntitySubType!=null)
            acc.Entity_Sub_Type__c = EntityDetails.EntitySubType;
        if(EntityDetails.EntityLicenseCategory!=null)
            acc.Category__c = EntityDetails.EntityLicenseCategory;
        
        /* CR051 DROP 2 CHANGES START ...*/
        if(EntityDetails.TotalAuthorisedSignatories!=null)
            acc.TotalAuthorisedSignatories__c = EntityDetails.TotalAuthorisedSignatories;
        /* CR051 END ...*/
        acc.Is_Initial_Approval__c = EntityDetails.IsCIDApproval;
        
        try{
            
            
            if(EntityDetails.CommercialLicense!=null && EntityDetails.CommercialLicense.FileId!=null && EntityDetails.CommercialLicense.FileId!=''){
                acc.Commercial_License_FileId__c = EntityDetails.CommercialLicense.FileId;
            }else{
                if(EntityDetails.IsCIDApproval == false){
                    objErrorResponse.Message = 'Error: Commercial License is required.';
                    return objErrorResponse;
                }
            }
            
            //upsert acc Entity_Id__c;
            
            //V2.0 : Since the entity id is also exists in CRM entities we cannot upsert the entity record based on Entity id as it could update the CRM entity instead of Reg entity.
            list<Account> account = [Select id from Account where Entity_Id__c=:acc.Entity_Id__c and Recordtypeid=:accRecordTypeId];
            if(!account.isEmpty()){
                acc.id = account[0].id;
                update acc;
            }else{
                insert acc;
            }
            
            //Don't Save the Commercial License in case of CID Approval
            if(EntityDetails.IsCIDApproval==false && EntityDetails.CommercialLicense!=null && EntityDetails.CommercialLicense.FileBody!=null && EntityDetails.CommercialLicense.FileBody!=''){
                Attachment att = new Attachment(Name=EntityDetails.CommercialLicense.FileName);
                att.Body = EncodingUtil.base64Decode(EntityDetails.CommercialLicense.FileBody);
                att.ContentType = EntityDetails.CommercialLicense.ContentType;
                att.Description = EntityDetails.CommercialLicense.FileId;
                att.ParentId = acc.Id;
                insert att;
                
                //Updating the Attachment Id in Entity
                Update_Role_AttachmentIds.updateEntityAttachmentIds_Future(acc.Id,att.Id);
            }
            list<Business_Activity__c> lstBA = new list<Business_Activity__c>();
            if(EntityDetails.BusinessActivities!=null && EntityDetails.BusinessActivities.size()>0){
                for(BusinessActivitiy objBA : EntityDetails.BusinessActivities){
                    //if(objBA.ActivityName!=null){
                        Business_Activity__c BA = new Business_Activity__c();
                        //BA.Activity_Name__c = objBA.ActivityName;
                        BA.Description__c = objBA.ActivityName;
                        if(objBA.ActivityNameArabic!=null)
                            BA.Description_Arabic__c = objBA.ActivityNameArabic;
                        /*
                        if(objBA.Description!=null)
                            BA.Description__c = objBA.Description;
                        if(objBA.DescriptionArabic!=null)
                            BA.Description_Arabic__c = objBA.DescriptionArabic;
                        */
                        BA.Entity__c = acc.Id;
                        if(objBA.ActivityCode!=null)
                            BA.Activity_Code__c = acc.Entity_Id__c+'-'+objBA.ActivityCode;
                        if(objBA.Section!=null)
                            BA.Section__c = objBA.Section;
                        if(objBA.Type!=null)
                            BA.Type__c = objBA.Type;
                        lstBA.add(BA);
                    //}
                }
            }
            if(lstBA.size()>0){
                list<Business_Activity__c> lstBATBD = [select Id from Business_Activity__c where Entity__c=:acc.Id];
                if(lstBATBD!=null && lstBATBD.size()>0)
                    delete lstBATBD;
                upsert lstBA;
            }
            if(EntityDetails.TradeNames!=null && EntityDetails.TradeNames.size()>0){
                Set<String> tradeNamesActive = new Set<String>();
                list<Trade_Name__c> lstTradeNames = new list<Trade_Name__c>();
                for(TradeName TName:EntityDetails.TradeNames){
                    if(TName.TradeName!=null){
                        Trade_Name__c TradeName = new Trade_Name__c();
                        TradeName.Entity__c = acc.Id;
                        TradeName.Name_in_English__c = TName.TradeName;
                        TradeName.Name_in_Arabic__c = TName.TradeNameArabic;
                        Tradename.Status__c = 'Active';
                        lstTradeNames.add(TradeName);
                        tradeNamesActive.add(TName.TradeName);
                    }
                }
                List<Trade_Name__c> tradeNameInactiveList = new List<Trade_Name__c>();
                if(tradeNamesActive.size()>0 && tradeNamesActive!=null){
                    for(Trade_Name__c tNameInactive : [SELECT Id, Status__c, Name_In_English__c FROM Trade_Name__c WHERE Entity__c=:acc.Id AND Name_In_English__c NOT IN :tradeNamesActive]){
                        tNameInactive.Status__c = 'Inactive';
                        tradeNameInactiveList.add(tNameInactive);
                    }
                }
                
                if(lstTradeNames.size()>0)
                    upsert lstTradeNames Name_In_English__c;
                    
                if(tradeNameInactiveList.size()>0)
                    update tradeNameInactiveList;
            }
            list<Address__c> lstAddresses = new list<Address__c>();
            if(EntityDetails.PhysicalAddress!=null && EntityDetails.PhysicalAddress.BuildingName!=null){
                Address adr = EntityDetails.PhysicalAddress;
                Address__c PhyAdr = new Address__c();
                PhyAdr.Type__c = 'Physical';
                PhyAdr.Building_Name__c = adr.BuildingName;
                PhyAdr.Country__c = adr.Country;
                PhyAdr.Emirates__c = adr.Emirates;
                PhyAdr.Entity__c = acc.Id;
                PhyAdr.Floor__c = adr.Floor;
                PhyAdr.Office_Number__c = adr.OfficeNumber;
                PhyAdr.State__c = adr.State;
                PhyAdr.Street_Name_of_Cluster_on_the_Island__c = adr.StreetName;
                lstAddresses.add(PhyAdr);
            }
            if(EntityDetails.PostalAddress!=null && EntityDetails.PostalAddress.Country!=null){
                Address adr = EntityDetails.PostalAddress;
                Address__c PostAdr = new Address__c();
                PostAdr.Type__c = 'Postal';
                PostAdr.Building_Name__c = adr.BuildingName;
                PostAdr.Country__c = adr.Country;
                PostAdr.Emirates__c = adr.Emirates;
                PostAdr.Entity__c = acc.Id;
                PostAdr.Floor__c = adr.Floor;
                PostAdr.Office_Number__c = adr.OfficeNumber;
                PostAdr.State__c = adr.State;
                PostAdr.Street_Name_of_Cluster_on_the_Island__c = adr.StreetName;
                if(adr.POBoxNumber!=null)
                    PostAdr.POBoxNumber__c = adr.POBoxNumber+'';
                lstAddresses.add(PostAdr);
            }
            if(lstAddresses.size()>0){
                list<Address__c> lstAdrressTBD = [select Id from Address__c where Entity__c=:acc.Id];
                if(lstAdrressTBD!=null && lstAdrressTBD.size()>0)
                    delete lstAdrressTBD;
                upsert lstAddresses;
            }
            objResp.SF_Entity_ID = acc.Id;
            objResp.StatusCode = '200';
        }catch(Exception e){
            objResp.SF_Entity_ID = 'Null';
            objResp.StatusCode = '600';
            objResp.Success = false;
            string MessageVal = e.getMessage()+'';
            if(MessageVal.indexOf('String length exceeds maximum: 6000000')>-1)
                MessageVal = 'String length exceeds maximum: 6000000';
            
            objResp.Message = MessageVal;
            
            //Create a log if there is any exception occurs.
            Log__c log = new Log__c(Cause__c=string.valueOf(e.getCause()),Line_Number__c=e.getLineNumber(),Message__c=e.getMessage(),
                                    Stack_Trace__c=e.getStackTraceString(),Type_Name__c=e.getTypeName(),
                                    User_Email__c=UserInfo.getUserEmail(),User_Name__c=UserInfo.getUserName(),
                                    WS_Type__c='Entity Creation',
                                    Additional_Information__c='Entity Id = '+EntityDetails.EntityId+' \n EntityDetails.EntityName='+EntityDetails.EntityName
                                    +'\n Expiry Date = '+EntityDetails.ExpiryDate+
                                    '\n Entity Status='+EntityDetails.RegistrationStatus+
                                    '\n Entity Type= '+EntityDetails.EntityType+
                                    '\n Entity Sub type = '+EntityDetails.EntitySubType+
                                    '\n Category= '+EntityDetails.EntityLicenseCategory+
                                    '\n Total Authorised Signatories ='+EntityDetails.TotalAuthorisedSignatories+
                                    '\n Commercial License '+EntityDetails.CommercialLicense.FileId
                            );
            insert log;
        }
        return objResp;
    }
    global class EntityInformation{
        webservice string EntityName;
        webservice string EntityNameArabic;
        webservice string EntityId;
        webservice string RegistrationDate;
        webservice string RegistrationStatus;
        webservice string ExpiryDate;
        webservice string EntityType;
        webservice string EntitySubType;
        webservice string EntityLicenseCategory;
        webservice boolean IsUpdate;
        webservice Document CommercialLicense;
        webservice list<TradeName> TradeNames;
        webservice list<BusinessActivitiy> BusinessActivities;
        webservice Address PhysicalAddress;
        webservice Address PostalAddress;
        
        /* CR051 DROP 2  ...*/
        webservice boolean IsCIDApproval;
        webservice Integer TotalAuthorisedSignatories;
        /* CR051 END ...*/
        
        global EntityInformation(){
            TradeNames = new list<TradeName>();
            BusinessActivities = new list<BusinessActivitiy>();
            CommercialLicense = new Document();
            PhysicalAddress = new Address();
            PostalAddress = new Address();
        }
    }
    global class TradeName{
        webservice string TradeName;
        webservice string TradeNameArabic;
    }
    global class BusinessActivitiy{
        webservice string ActivityName;
        webservice string ActivityNameArabic;
        webservice string Description;
        webservice string DescriptionArabic;
        webservice string ActivityCode;
        webservice string Type;
        webservice string Section;
    }
    global class Document{
        webservice string FileName;
        webservice string ContentType;
        webservice string FileBody;//Base64 string
        webservice string FileId;
    }
    global class Address{
        webservice string OfficeNumber;
        webservice string Floor;
        webservice string BuildingName;
        webservice string StreetName;
        webservice string State;
        webservice string Emirates;
        webservice string Country;
        webservice string POBoxNumber;
    }
    global class ResponseDetails{
        webservice string SF_Entity_ID;
        webservice string EntityId;
        webservice boolean Success;
        webservice string Message;
        webservice string StatusCode;
    }
}