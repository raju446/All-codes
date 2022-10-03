/*
    Author      : Durga Kandula
    Date        : 16-Jul-2020
    Description : REST API class to accept the lead information from FSRA and create it as Lead Entity and Lead Contact.
	History:
	Naman Sharma	21-Sept-'21		Commented out lead contact related lines
	Naman Sharma 	7-Oct-'21		Removed debug statements having PII
	Prachi			 6-Jan-22		Retained the original value of main sector value in CRM for manually created leads
    --------------------------------------------------------------------------------------------------------------------
*/

@RestResource(urlMapping='/REST_FSRA_Leads/*')
global without sharing class REST_FSRA_Leads {
    @HttpPost
    global static ResponseDetails ProcessLeadData(){
    	REST_FSRA_Leads.ResponseDetails objResp = new REST_FSRA_Leads.ResponseDetails();
    	string RequestString = RestContext.request.requestBody.tostring();
    	RequestDetails objRequestWrap = (RequestDetails)JSON.deserialize(RequestString,RequestDetails.class);
    	string LeadEntityRecordTypeId;
		string LeadContactRecordTypeId;
		for(RecordType rc:[Select Id,developername from RecordType where sObjectType='Lead' and IsActive=true]){
			if(rc.DeveloperName=='Lead_Entity')
				LeadEntityRecordTypeId = rc.Id;
			/*else if(rc.DeveloperName=='Lead_Contact')
				LeadContactRecordTypeId = rc.Id;*/
		}
    	try{
    		if(objRequestWrap.LeadEntity!=null){
    			if(objRequestWrap.LeadEntity.LastName!=null){
    				objRequestWrap.LeadEntity.RecordTypeId = LeadEntityRecordTypeId;
                    //Checkbox FROM FSRA 
                    objRequestWrap.LeadEntity.From_FSRA__c = true;  
					
					//Retained the original value of main sector value in CRM for manually created leads
					for(Lead leadRecord : [select id, Main_sector__c, Sector__c, Sub_Sector__c from lead where id =: objRequestWrap.LeadEntity.Id]){
						if(leadRecord.Main_sector__c != null){
							objRequestWrap.LeadEntity.Main_sector__c = leadRecord.Main_sector__c;
						}
						if(objRequestWrap.LeadEntity.Sector__c == null && leadRecord.Sector__c != null){
							objRequestWrap.LeadEntity.Sector__c = leadRecord.Sector__c;
						}
						if(objRequestWrap.LeadEntity.Sub_Sector__c == null && leadRecord.Sub_Sector__c != null){
							objRequestWrap.LeadEntity.Sub_Sector__c = leadRecord.Sub_Sector__c;
						}
					}

    				upsert objRequestWrap.LeadEntity;
    			}
    			
    			/*list<Lead> lstLeadContacts = new list<Lead>();
    			if(objRequestWrap.LeadContacts!=null && objRequestWrap.LeadContacts.size()>0 && objRequestWrap.LeadEntity.Id!=null){
	    			for(Lead ld:objRequestWrap.LeadContacts){
	    				ld.RecordTypeId = LeadContactRecordTypeId;
	    				ld.Related_Lead_Entity__c = objRequestWrap.LeadEntity.Id;
                        //Checkbox FROM FSRA
                       	ld.From_FSRA__c = true;
	    				lstLeadContacts.add(ld);
	    			}
    			}
    			if(lstLeadContacts.size()>0)
    				upsert lstLeadContacts;*/
    				
    		}
    		objResp.bSuccess = true;
    		objResp.StatusCode = '201';
    		objResp.Message = 'Success';
    	}catch(DMLException e){
    		string DMLError = e.getdmlMessage(0)+'';
        	if(DMLError==null)
            	DMLError = e.getMessage()+'';
    		objResp.bSuccess = false;
    		objResp.StatusCode = '500';
    		objResp.Message = DMLError;
    	}
        Log__c objLog = new Log__c();
        objLog.Message__c = objResp.Message;
        objLog.Additional_Information__c = RequestString;
        objLog.Type_Name__c = 'REST_FSRA_Leads';
		insert objLog;        
    	return objResp;
    }
    global class RequestDetails{
    	global Lead LeadEntity;
    	//global list<Lead> LeadContacts;
    }
    global class ResponseDetails{
        global boolean bSuccess;
        global string StatusCode;
        global string Message;
        global ResponseDetails(){
        	bSuccess = true;
        }
    }
}