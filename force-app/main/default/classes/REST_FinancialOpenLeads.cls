/*
    Author      : Durga Kandula
    Date        : 10-Aug-2020
    Description : REST API class to send the financial leads which are open to FSRA Org.
    ------------------------------------------------------------------------------------
	History:
	19-Sept-'21: Naman: Added FSRA_Sector__c to the strQuery
						Updated to have FSRA_Sector__c in the filter query
	21-Sept-'21: Naman: Commented out contact related fields
	22-Sept-'21: Naman: Commented out fields from query that are not required
	7-Oct-'21: Naman:  Removed debug statements
	1-Nov-'21: Naman: Updated 'StatusValues' to take multiple lead status values through custom label
	4-Nov-'21: Naman: Removed 'StatusValues', instead using isConverted=false in query
*/
@RestResource(urlMapping='/REST_FinancialOpenLeads/*')

global without sharing class REST_FinancialOpenLeads {
    @HttpPost
    global static list<Lead> SearchLeads(){
        list<Lead> listFinancialLeads = new list<Lead>();
        string RequestString = RestContext.request.requestBody.tostring();
        searchWrapper filters = (searchWrapper) JSON.deserialize(RequestString, searchWrapper.class);
        
        //list<string> StatusValues = new list<string>{Label.Converted_Lead_Status, 'Converted'};//,'Not Interested','Duplicate','Invalid','Unqualified'};        
        string strCategory = 'Financial';
        string strRecordTypeName = 'Lead_Entity';
        //String StatusValuesLabel = Label.Converted_Lead_Status;
        //List<String> StatusValues = StatusValuesLabel.split(',');
        //string strQuery = 'Select Id,FirstName,LastName,Company,Email,FSRA_Sector__c,Main_Sector__c,Status,LeadSource,CreatedDate,LastModifiedDate,(Select Id,FirstName,LastName,Company,Email,Main_Sector__c from Parent_Lead__r) from Lead where Category__c=:strCategory and Recordtype.DeveloperName=:strRecordTypeName and Status NOT IN:StatusValues';
        //string strQuery = 'Select Id,Company,Email,FSRA_Sector__c,Main_Sector__c,Status,LeadSource,CreatedDate,LastModifiedDate from Lead where Category__c=:strCategory and Recordtype.DeveloperName=:strRecordTypeName and Status NOT IN:StatusValues';
        string strQuery = 'Select Id,Company,Email,FSRA_Sector__c,Main_Sector__c,Status,LeadSource,CreatedDate,LastModifiedDate from Lead where Category__c=:strCategory and Recordtype.DeveloperName=:strRecordTypeName and isConverted=false';        
        
        string CompanyName = '%'+filters.companyName+'%';
        string MainSector = filters.leadSector;
        string EmailAddress = '%'+filters.leadEmail+'%';
        string LeadStatus = filters.leadStatus;
        string Source = filters.leadSource;
        
        if(filters.companyName!=null)
        	strQuery = strQuery+' and Company LIKE:CompanyName';
        if(filters.leadSector!=null)
        	strQuery = strQuery+' and FSRA_Sector__c=:MainSector';
    	if(filters.leadEmail!=null)
        	strQuery = strQuery+' and Email LIKE: EmailAddress';
        if(filters.leadStatus!=null)
        	strQuery = strQuery+' and Status=:LeadStatus';
        if(filters.leadSource!=null)
        	strQuery = strQuery+' and LeadSource=:Source';
        	
        strQuery = strQuery+' Order by LastModifiedDate desc';
        
        
        for(Lead ld:database.query(strQuery)){
        //[Select Id,FirstName,LastName,Company,Email,Main_Sector__c,Status,LeadSource,CreatedDate,LastModifiedDate,(Select Id,FirstName,LastName,Company,Email,Main_Sector__c from Parent_Lead__r) from Lead where Category__c='Financial' and Recordtype.DeveloperName='Lead_Entity' and Status NOT IN:StatusValues Order by LastModifiedDate desc]
        	listFinancialLeads.add(ld);
        }
        return listFinancialLeads;
    }
    public class searchWrapper{
        public string companyName{get; set;}
        public string leadSector{get; set;}
        public string leadEmail{get; set;}
        public string leadStatus{get; set;}
        public string leadSource{get;set;}
    }
}