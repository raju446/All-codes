/*
@Author : Azmath.
@Description : The webservice class for ADP to fetch the documents.
*/
@RestResource(urlMapping='/GetDocuments/*')
global  without sharing class ADP_DownloadDocuments 
{
    @HttpPost
    global static documents getdocuments()
    {
    	documents doc;
    	list<HexaBPM__SR_Doc__c> srdoc;
    	try{
    		RequestWrap req   = new RequestWrap();
	    	req = (RequestWrap)System.JSON.deserialize(RestContext.request.requestBody.tostring(),RequestWrap.class);
	        system.debug('=====req==='+req);
	        if(req.Document_ID != null && req.Document_ID != '')
	        {
		        srdoc = [Select id,name from HexaBPM__SR_Doc__c where id=:req.Document_ID];
		        if(!srdoc.isEmpty())
		        {
		        	for(Attachment att : [select id, Name, Body, ContentType, BodyLength  from attachment where parentid=:req.Document_ID order by CreatedDate DESC Limit 1])
			        {
		        		string attname 	= att.Name;
			    		doc 			= new documents();
			    		doc.O_ID 		= string.valueof(srdoc[0].Id).substring(0,15);
			    		doc.O_Name 		= srdoc[0].Name;
			    		doc.O_MimeType 	= att.ContentType;
			    		doc.O_FileName 	= att.Name;	
			    		if(att.BodyLength != null && att.BodyLength != 0)
			    			doc.O_FileSize 	= (att.BodyLength/1024)+'KB';
			    		doc.O_Content 	= EncodingUtil.base64Encode(att.Body);
			        }
		        }
	        }
	        if(req.Document_ID == null || req.Document_ID =='' || srdoc.isEmpty())
	        {
	        	doc 	= new documents();
	        	doc.O_Message = 'Invalid Document Id';
	        	doc.O_StatusCode = '600';
	        }
    	}catch(Exception ex){
    		system.debug('===exception =='+ex.getMessage());
    		doc 	= new documents();
        	doc.O_Message = 'Something went wrong, please contact system administrator.';
        	doc.O_StatusCode = '600';
    	}
        
        return doc;
    }
    
    global class documents
    {
    	public string O_ID;
	    public string O_Name;
	    public string O_MimeType;
	    public string O_FileName;
	    public string O_FileSize;
	    public string O_Content;
	    public string O_Message;
	    public string O_StatusCode;
    }
    global class RequestWrap{
        global string Document_ID;
    }
    /*
    global class ResponseDetails{
        global string O_Status;
        global string O_StatusCode;
        global String O_Message;
    }*/
}