public without sharing class DED_RestServicesHelper 
{
    public static list<DED_Sub_Log__c> issueBLFZEDServiceRequest(Account acc)
    {
    	list<DED_Sub_Log__c> sublogs = new list<DED_Sub_Log__c>();
    	DED_Json helper = new DED_Json(acc);
		string payload = JSON.serialize(helper);
		payload = payload.replaceALL('modifyBLED','issueBLED');
		system.debug('==payload==='+payload);
		
    	HttpRequest req = new HttpRequest();
    	if(system.label.IsSandBox == 'TRUE')
    		 req.setEndpoint('callout:Informatica_URL/IssueBLFZEDProcess_OnPrem');
    	else
    		req.setEndpoint('callout:Informatica_URL/IssueBLFZEDProcess_Prod');
		//req.setEndpoint('https://informaticauat.adgm.com:443/process-engine/rt/IssueBLFZEDProcess_OnPremise');
		req.setMethod('POST');
		req.setTimeout(60000);
		req.setHeader('content-type','application/json;charset=UTF-8;');
		req.setBody(payload);
		Http http = new Http();
		HTTPResponse objRespWrap = http.send(req);
		if(objRespWrap.getStatusCode() == 200)
		{
			system.debug('===response body==='+objRespWrap.getBody());
			DED_ResponseJson response = (DED_ResponseJson) System.JSON.deserialize(objRespWrap.getBody(), DED_ResponseJson.class);
			if(response != null)
			{
				DED_ResponseJson.IssueBLFZEDResult issueResult =  response.UD_Output.issueBLFZEDResult;
				DED_Log__c log 			= new DED_Log__c();
				log.Entity__c 			= acc.id;
				log.WS_Type__c 			= 'IssueBLFZED';
				log.CBLSSubmissionID__c = issueResult.CBLSSubmissionID;
				log.FCRNumber__c 		= issueResult.FCRNumber;
				insert log;
				
				for(DED_ResponseJson.CBLSResponseMessage msg : issueResult.message.CBLSResponseMessage)
				{
				    DED_Sub_Log__c sl = new DED_Sub_Log__c();
					sl.log__c = log.id;
					sl.Message_Text__c = msg.MessageTextEN;
					if(msg.MessageCode != null)
						sl.Message_Code__c = string.valueof(msg.MessageCode);
					if(msg.MessageType != null)
						sl.Message_Type__c = string.valueof(msg.MessageType);
					sublogs.add(sl);
				}
				if(!sublogs.isEmpty()){
					insert sublogs;
				}
			}
		}
		else{
			sublogs = processErrorResponse(objRespWrap,acc.id,'IssueBLFZED');
		}
    	return sublogs;
    }
    public static list<DED_Sub_Log__c> modifyBLFZEDServiceRequest(Account acc)
    {
    	list<DED_Sub_Log__c> sublogs = new list<DED_Sub_Log__c>();
    	DED_Json helper = new DED_Json(acc);
		string payload = JSON.serialize(helper);
		system.debug('==payload==='+payload);
		
    	HttpRequest req = new HttpRequest();
    	if(system.label.IsSandBox == 'TRUE')
    		req.setEndpoint('callout:Informatica_URL/ModifyBLFZEDProcess_OnPrem');
    	else
    		req.setEndpoint('callout:Informatica_URL/ModifyBLFZEDProcess_Prod');
		req.setMethod('POST');
		req.setTimeout(60000);
		req.setHeader('content-type','application/json;charset=UTF-8;');
		req.setBody(payload);
		Http http = new Http();
		HTTPResponse objRespWrap = http.send(req);
		if(objRespWrap.getStatusCode() == 200)
		{
			system.debug('===response body==='+objRespWrap.getBody());
			DED_ResponseJson response = (DED_ResponseJson) System.JSON.deserialize(objRespWrap.getBody(), DED_ResponseJson.class);
			if(response != null)
			{
				DED_ResponseJson.ModifyBLFZEDResult issueResult =  response.UD_Output.modifyBLFZEDResult;
				DED_Log__c log 			= new DED_Log__c();
				log.Entity__c 			= acc.id;
				log.WS_Type__c 			= 'modifyBLFZED';
				log.CBLSSubmissionID__c = issueResult.CBLSSubmissionID;
				log.FCRNumber__c 		= issueResult.FCRNumber;
				insert log;
				
				for(DED_ResponseJson.CBLSResponseMessage msg : issueResult.message.CBLSResponseMessage)
				{
				    DED_Sub_Log__c sl = new DED_Sub_Log__c();
					sl.log__c = log.id;
					sl.Message_Text__c = msg.MessageTextEN;
					if(msg.MessageCode != null)
						sl.Message_Code__c = string.valueof(msg.MessageCode);
					if(msg.MessageType != null)
						sl.Message_Type__c = string.valueof(msg.MessageType);
					sublogs.add(sl);
				}
				if(!sublogs.isEmpty()){
					insert sublogs;
				}
			}
		}
		else{
			sublogs = processErrorResponse(objRespWrap,acc.id,'ModifyBLFZED');
		}
    	return sublogs;
    }
    public static list<DED_Sub_Log__c> renewBLFZEDServiceRequest(Account acc)
    {
    	list<DED_Sub_Log__c> sublogs = new list<DED_Sub_Log__c>();
    	RenewBLFZEDParser helper = new RenewBLFZEDParser(acc);
		string payload = JSON.serialize(helper);
		system.debug('==payload==='+payload);
		
    	HttpRequest req = new HttpRequest();
    	if(system.label.IsSandBox == 'TRUE')
    		 req.setEndpoint('callout:Informatica_URL/renewBLFZED_OnPremise');
    	else
    		req.setEndpoint('callout:Informatica_URL/renewBLFZED_Prod');
		//req.setEndpoint('https://informaticauat.adgm.com:443/process-engine/rt/IssueBLFZEDProcess_OnPremise');
		req.setMethod('POST');
		req.setTimeout(60000);
		req.setHeader('content-type','application/json;charset=UTF-8;');
		req.setBody(payload);
		Http http = new Http();
		HTTPResponse objRespWrap = http.send(req);
		if(objRespWrap.getStatusCode() == 200)
		{
			system.debug('===response body==='+objRespWrap.getBody());
			DED_ResponseJson response = (DED_ResponseJson) System.JSON.deserialize(objRespWrap.getBody(), DED_ResponseJson.class);
			if(response != null)
			{
				DED_ResponseJson.RenewBLFZEDResult issueResult =  response.UD_Output.renewBLFZEDResult;
				DED_Log__c log 			= new DED_Log__c();
				log.Entity__c 			= acc.id;
				log.WS_Type__c 			= 'renewBLFZED';
				log.CBLSSubmissionID__c = issueResult.CBLSSubmissionID;
				log.FCRNumber__c 		= issueResult.FCRNumber;
				insert log;
				
				for(DED_ResponseJson.CBLSResponseMessage msg : issueResult.message.CBLSResponseMessage)
				{
				    DED_Sub_Log__c sl = new DED_Sub_Log__c();
					sl.log__c = log.id;
					sl.Message_Text__c = msg.MessageTextEN;
					if(msg.MessageCode != null)
						sl.Message_Code__c = string.valueof(msg.MessageCode);
					if(msg.MessageType != null)
						sl.Message_Type__c = string.valueof(msg.MessageType);
					sublogs.add(sl);
				}
				if(!sublogs.isEmpty()){
					insert sublogs;
				}
			}
		}
		else{
			sublogs = processErrorResponse(objRespWrap,acc.id,'RenewBLFZED');
		}
    	return sublogs;
    }
    public static list<DED_Sub_Log__c> cancelBLFZEDServiceRequest(Account acc)
    {
    	list<DED_Sub_Log__c> sublogs = new list<DED_Sub_Log__c>();
    	CancelBLFZEDParser helper = new CancelBLFZEDParser(acc);
		string payload = JSON.serialize(helper);
		system.debug('==payload==='+payload);
		
    	HttpRequest req = new HttpRequest();
    	if(system.label.IsSandBox == 'TRUE')
    		 req.setEndpoint('callout:Informatica_URL/cancelBLFZED_OnPremise');
    	else
    		req.setEndpoint('callout:Informatica_URL/cancelBLFZED_Prod');
		//req.setEndpoint('https://informaticauat.adgm.com:443/process-engine/rt/IssueBLFZEDProcess_OnPremise');
		req.setMethod('POST');
		req.setTimeout(60000);
		req.setHeader('content-type','application/json;charset=UTF-8;');
		req.setBody(payload);
		Http http = new Http();
		HTTPResponse objRespWrap = http.send(req);
		if(objRespWrap.getStatusCode() == 200)
		{
			system.debug('===response body==='+objRespWrap.getBody());
			DED_ResponseJson response = (DED_ResponseJson) System.JSON.deserialize(objRespWrap.getBody(), DED_ResponseJson.class);
			if(response != null)
			{
				DED_ResponseJson.CancelBLFZEDResult issueResult =  response.UD_Output.cancelBLFZEDResult;
				DED_Log__c log 			= new DED_Log__c();
				log.Entity__c 			= acc.id;
				log.WS_Type__c 			= 'CancelBLFZED';
				log.CBLSSubmissionID__c = issueResult.CBLSSubmissionID;
				log.FCRNumber__c 		= issueResult.FCRNumber;
				insert log;
				
				for(DED_ResponseJson.CBLSResponseMessage msg : issueResult.message.CBLSResponseMessage)
				{
				    DED_Sub_Log__c sl = new DED_Sub_Log__c();
					sl.log__c = log.id;
					sl.Message_Text__c = msg.MessageTextEN;
					if(msg.MessageCode != null)
						sl.Message_Code__c = string.valueof(msg.MessageCode);
					if(msg.MessageType != null)
						sl.Message_Type__c = string.valueof(msg.MessageType);
					sublogs.add(sl);
				}
				if(!sublogs.isEmpty()){
					insert sublogs;
				}
			}
		}
		else{
			sublogs = processErrorResponse(objRespWrap,acc.id,'CancelBLFZED');
		}
    	return sublogs;
    }
    public static list<DED_Sub_Log__c> processErrorResponse(HTTPResponse objRespWrap,Id accid, string wtype)
    {
    	list<DED_Sub_Log__c> sublogs = new list<DED_Sub_Log__c>();
    	DED_Log__c log 	= new DED_Log__c(Entity__c=accid,WS_Type__c=wtype);
    	insert log;
    	DED_Sub_Log__c sl = new DED_Sub_Log__c(log__c=log.id, Message_Code__c=string.valueof(objRespWrap.getStatusCode()), Error_Description__c=objRespWrap.getBody());
    	insert sl;
    	sublogs.add(sl);
    	return sublogs;
    }
}