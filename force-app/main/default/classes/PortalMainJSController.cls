/*
 * Created on Mon Oct 09 2017
 * Author: Rajil
 * Purpose: Gets the Profile photo of the loggedin user on the header.
 * Copyright (c) 2017 PwC
*/

global without sharing class PortalMainJSController{

    public string profilePicId {get;set;}
    public string accountName {get;set;}
    public string accId {get;set;}
    public string entityNumber {get;set;}
    public string EChannelAccountNumber {get;set;}
    public string EChannelExpiryDate {get;set;}
    public string estExpiryDate {get;set;}
    public string estCardNumber {get;set;}
    public string estIssueDate {get;set;}
    
    public string ContactEmail{get;set;}
    public string ContactPhone{get;set;}
    
    public string poboxType {get;set;}
    public string jsonTranslateFields {get;set;}
    public string jsonSRDtl {get;set;}

    public static HexaBPM__Service_Request__c serviceRequest { get; set; }

    public PortalMainJSController()
    {
        profilePicId = 'no-pic';
        accountName = '';
        User[] user = [select contact.Profile_Picture_Id__c,Contact.Email,Contact.MobilePhone,contact.Account.Name,contact.Account.Id,contact.account.Entity_Id__c,contact.account.EChannel_Account_Number__c,
                        contact.account.Establishment_Card_Expiry_Date__c,contact.account.Establishment_Card_No__c,contact.account.EChannel_Expiry_Date__c,contact.account.Establishment_Card_Issue_Date__c,contact.account.PO_Box__r.Type__c from user
                         where id =: Userinfo.getUserid()];
                    
        if(user.size() > 0)
        {
            ContactEmail = user[0].contact.Email;
            ContactPhone = user[0].contact.MobilePhone;
            profilePicId = user[0].contact.Profile_Picture_Id__c;
            accountName = user[0].contact.Account.Name;
            accId = user[0].contact.Account.Id;
            entityNumber = user[0].contact.account.Entity_Id__c;
            EChannelAccountNumber = user[0].contact.account.EChannel_Account_Number__c;
            poboxType = user[0].contact.account.PO_Box__r.Type__c;
            if(user[0].contact.account.EChannel_Expiry_Date__c != null)
                EChannelExpiryDate = DateTime.newInstance(user[0].contact.account.EChannel_Expiry_Date__c.year(), user[0].contact.account.EChannel_Expiry_Date__c.month(), user[0].contact.account.EChannel_Expiry_Date__c.day()).format('MM/dd/yyyy');
                //EChannelExpiryDate = user[0].contact.account.EChannel_Expiry_Date__c; Establishment_Card_Expiry_Date__c
            if(user[0].contact.account.Establishment_Card_Expiry_Date__c != null)
                estExpiryDate = DateTime.newInstance(user[0].contact.account.Establishment_Card_Expiry_Date__c.year(), user[0].contact.account.Establishment_Card_Expiry_Date__c.month(), user[0].contact.account.Establishment_Card_Expiry_Date__c.day()).format('MM/dd/yyyy');
            if(user[0].contact.account.Establishment_Card_Issue_Date__c != null)
                estIssueDate = DateTime.newInstance(user[0].contact.account.Establishment_Card_Issue_Date__c.year(), user[0].contact.account.Establishment_Card_Issue_Date__c.month(), user[0].contact.account.Establishment_Card_Issue_Date__c.day()).format('MM/dd/yyyy');
            estCardNumber = user[0].contact.account.Establishment_Card_No__c;
            
            //Gets the field ids -> Source and Destination for Arabic translation from custom setting.
            List<TranslateFields__c> lstTranslateFields = new List<TranslateFields__c>();
            lstTranslateFields  = TranslateFields__c.getAll().values();
            if(lstTranslateFields.size() > 0){
                jsonTranslateFields = JSON.serialize(lstTranslateFields);
            }
        }
        
    }
    public void getSRDetail(){
        string srID = ApexPages.currentPage().getParameters().get('srID');
        string srType = ApexPages.currentPage().getParameters().get('srType');
        if(string.isNotEmpty(srID)){
            list<SRInfo> lstSRInfo = new list<SRInfo>();
            for(HexaBPM__Service_Request__c serviceRequest : [SELECT HexaBPM__Submitted_DateTime__c, HexaBPM__SR_Template__r.Disclaimer_Text__c from HexaBPM__Service_Request__c WHERE id = :srID and HexaBPM__Customer__c= :accId]){
                SRInfo srInforObj = new SRInfo();
                srInforObj.srSubmittedDateTime = serviceRequest.HexaBPM__Submitted_DateTime__c;
                srInforObj.disclaimerText = serviceRequest.HexaBPM__SR_Template__r.Disclaimer_Text__c;
                lstSRInfo.add(srInforObj);
            }
            jsonSRDtl = JSON.serialize(lstSRInfo);
        }
        else if(string.isNotEmpty(srType)){
            list<SRTemplate> lstSRTemplate = new list<SRTemplate>();
            for(HexaBPM__SR_Template__c srTemplate  : [select Disclaimer_Text__c,HexaBPM__SR_Description__c from HexaBPM__SR_Template__c where HexaBPM__SR_RecordType_API_Name__c = :srType]){
                SRTemplate srTemplateObj = new SRTemplate();
                srTemplateObj.disclaimerText = srTemplate.Disclaimer_Text__c;
                srTemplateObj.srTemplateDescription = srTemplate.HexaBPM__SR_Description__c;
                lstSRTemplate.add(srTemplateObj);
            }
            jsonSRDtl = JSON.serialize(lstSRTemplate);
        }
        
    }
    public class SRInfo{
        public datetime srSubmittedDateTime {get;set;}
        public string disclaimerText {get;set;}
    }
    public class SRTemplate{
        public string disclaimerText {get;set;}
        public string srTemplateDescription {get;set;}
    }
    
}