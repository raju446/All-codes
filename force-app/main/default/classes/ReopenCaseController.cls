public without sharing class ReopenCaseController{
    public Boolean ShowpageBlockFlag{get;set;}
    public Boolean Showreqfeild{get;set;}
    public string comments {get;set;}
    public string selectedValue{get;set;}
    public boolean isSubmitted{get;set;}
    //public String maskedComment {get;set;}
    public  ReopenCaseController(){
        ShowpageBlockFlag = false;
        isSubmitted = false;
        Showreqfeild= false;
        selectedValue='--Select--';
    }
    public List<SelectOption> getItems(){
	    list<SelectOption> options = new list<SelectOption>();
	    options.add(new SelectOption('--Select--','--Select--'));
	    options.add(new SelectOption('My case was not resolved successfully','My case was not resolved successfully'));
	    options.add(new SelectOption('I require additional information on this case','I require additional information on this case'));
	    options.add(new SelectOption('Needs additional new information','Needs additional new information'));
	    return options;
    }
    public  PageReference reopenCaseEmail(){ //Reopen case from email
        //string caseId = ApexCodeUtility.getDecryptedValue(ApexPages.currentPage().getParameters().get('caseId'));
        string caseId = ApexPages.currentPage().getParameters().get('caseId');
        string contactEmail = ApexPages.currentPage().getParameters().get('email');
        string reply = 'no';
        system.debug('comments===>'+comments);
        reply = ApexPages.currentPage().getParameters().get('reply');
        if(string.IsNotEmpty(caseId)){
        	group queue =[select Id from Group where Type = 'Queue' AND NAME = 'Client Support Centre' limit 1];
            System.debug('caseID'+caseId);
            system.debug('contactEmail'+contactEmail);
            list<Case> caseRec = [select id,Queue_Name__c,ownerId,CRM_Company__c,CRM_First_Name__c,CRM_Last_Name__c,Email_Address__c,CRM_Mobile__c,CRM_Phone__c,status,comments,origin,CRM_Reason_for_case_re_opening__c,New_Case_Opened__c,
            ContactId,Subject,CRM_Reopen_Additional_details__c,SuppliedName,SuppliedEmail,Recordtypeid,Case_Re_Open_Count__c,Is_Case_Reopened__c from Case where ID = :caseId  and status = 'Closed'];
            System.debug('caseRec.size()'+caseRec);
            
            if(caseRec!=null && caseRec.size() > 0 )
            {
	           if(caseRec[0].New_Case_Opened__c == false)
	           {	system.debug('sel123='+selectedValue);
	                if(selectedValue != '--Select--'  && String.IsNotEmpty(comments))
	                {   
	                	if(selectedValue == 'Needs additional new information')
	                	{ 
                          	system.debug('selctedValue new case will be created');  
	                		Case newcase = new Case();
	                		newcase.parentId 							= caseRec[0].id;
	                		newcase.status 								= 'New';
	                		newcase.CRM_Reason_for_case_re_opening__c 	= selectedValue;
	                		newcase.Description  						= comments;
	                		newcase.CRM_Reopen_Additional_details__c  	= comments;
	                		newcase.CRM_Company__c  					= caseRec[0].CRM_Company__c;
	                		newcase.CRM_First_Name__c  					= caseRec[0].CRM_First_Name__c;
	                		newcase.CRM_Last_Name__c  					= caseRec[0].CRM_Last_Name__c;
	                		newcase.Email_Address__c  					= caseRec[0].Email_Address__c;
	                		newcase.CRM_Mobile__c  						= caseRec[0].CRM_Mobile__c;
	                		newcase.CRM_Phone__c  						= caseRec[0].CRM_Phone__c;
	                		newcase.ContactId  							= caseRec[0].ContactId;
	                		newcase.Subject  							= caseRec[0].Subject;
	                		newcase.Recordtypeid						= caseRec[0].Recordtypeid;
	                		newcase.SuppliedEmail						= caseRec[0].SuppliedEmail;
	                		newcase.SuppliedName						= caseRec[0].SuppliedName;
	                		newcase.ownerId								= caseRec[0].OwnerId;
	                		newCase.Origin								= caseRec[0].Origin;
	                		/*if(caseRec[0].Origin == 'CSC - RA'){
		                    	newcase.OwnerId = label.CSC_RA;
		                    	newcase.Queue_Name__c = 'CSC - RA';
		                    	newCase.Origin = 'CSC - RA';
		                    	newcase.CRM_Bypass_Assignment_Rule__c = true;
		                    }else if(caseRec[0].Origin == 'CSC - Monitoring'){
		                    	newcase.OwnerId = label.CSC_Monitoring;
		                    	newcase.Queue_Name__c = 'CSC - Monitoring';
		                    	newCase.Origin = 'CSC - Monitoring';
		                    	newcase.CRM_Bypass_Assignment_Rule__c = true;
		                    }else{*/
		                    // }
		                    
                            if( string.valueOf(caseRec[0].OwnerId).startsWith('005')) { // change for fix -all reopen cases are getting assigned to client service queue. Assign case to resp group if owner was user
                                List<User> ownerProfile =[SELECT id, Profile.Name, Profile.Id FROM User WHERE id=:caseRec[0].OwnerId];
                                if( ownerProfile.size()>0){ 
                                    if(ownerProfile[0].Profile.Name.contains('Government Services') || caseRec[0].Origin == 'Email'){
                                        system.debug('in owner change='+ownerProfile[0].Profile.Name );
                                        group govServiceQueue =[select Id from Group where Type = 'Queue' AND NAME = 'Government Services Team' limit 1];
                                        newcase.OwnerId = govServiceQueue.id;
                                    } else {
                                        newcase.OwnerId = queue.Id;
                                    }
                                }
                            }
                            
	                		insert newcase;
	                		caseRec[0].New_Case_Opened__c = true;
	                		update caseRec[0];
	                		
	                		PageReference thankyouPage = new PageReference('/apex/Reopen_Thankyou');
			                thankyouPage.setRedirect(true);
			                return thankyouPage;
	                	}
	                	else
	                	{
                            system.debug('else selected value = case will be reopened');
	                		Decimal counter = 0;
	                		if(caseRec[0].Case_Re_Open_Count__c != null){
	                			counter = caseRec[0].Case_Re_Open_Count__c;
	                		}
	                		caseRec[0].CRM_Reason_for_case_re_opening__c= selectedValue;
		                    caseRec[0].CRM_Reopen_Additional_details__c  = comments;
		                    caseRec[0].comments = 'Case Re-open Reason: '+ selectedValue +'.'+ '\r\n'+'Additional Details: '+ comments;
		                    caseRec[0].CRM_Has_Unread_Comments__c = true;
		                    caseRec[0].Status = 'Re-Open';
		                    caseRec[0].Is_Case_Reopened__c = true;
		                    
		                    caseRec[0].Case_Re_Open_Count__c = counter + 1;
                            
                            // change for fix -all reopen cases are getting assigned to client service queue. Assign case to resp group if owner was user
                            if( string.valueOf(caseRec[0].OwnerId).startsWith('005') ) {
                                List<User> ownerProfile = [SELECT id, Profile.Name, Profile.Id FROM User WHERE id=:caseRec[0].OwnerId];
                                if( ownerProfile.size()>0){
                                    if(ownerProfile[0].Profile.Name.contains('Government Services') || caseRec[0].Origin == 'Email' ){
                                        system.debug('in owner change='+ownerProfile[0].Profile.Name );
                                        group govServiceQueue =[select Id from Group where Type = 'Queue' AND NAME = 'Government Services Team' limit 1];
                                        caseRec[0].OwnerId = govServiceQueue.id;
                                    } else {
                                        system.debug('in owner change===='+ownerProfile[0].Profile.Name );
                                        caseRec[0].OwnerId = queue.Id;
                                    }
                                }
                            }
		                    /*if(caseRec[0].Origin == 'CSC - RA'){
		                    	caseRec[0].OwnerId = label.CSC_RA;
		                    }else if(caseRec[0].Origin == 'CSC - Monitoring'){
		                    	caseRec[0].OwnerId = label.CSC_Monitoring;
		                    }else{*/
                            
		                    	// caseRec[0].OwnerId = queue.id; //this line commented  Shagufta : removed the logic to assign all case to client service queue
		                    
		                    caseRec[0].CRM_Update_counter__c = 0;
		                    caseRec[0].Re_opened_Date__c = system.now();
		                	CaseTriggerHelper.OwnerChangeFromButton = false;
				            try{
			                   	update caseRec;
			                   	PageReference thankyouPage = new PageReference('/apex/Reopen_Thankyou');
			                   	thankyouPage.setRedirect(true);
			                   	return thankyouPage;
			        		}catch(Exception ex){
				               	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
			        		}
	                	}
	            	}
	           }
	           else{
	           		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A new case has already been created. So you cannot Reopen/open a case.'));
	           }
            }
            else
            {
                isSubmitted = true; 
            }
    	}
    	return null;
    }
    @AuraEnabled // reopening from lightning button.
    public static map<boolean,string> ReopenData(string CaseId){
    	system.debug('======'+caseId);
        map<boolean,string> m1 = new map<boolean,string>();
        string CaseOwnerId;
        string strResult  = 'You are not allowed to do this operation.';
        boolean hasAccess = false;
        Case caseRec = [SELECT OwnerId,IsClosed,status  FROM Case WHERE Id = :CaseId];
        CaseOwnerId = caseRec.OwnerId;
        if(caseRec.IsClosed == false){
            strResult ='Case is already Open.';
            m1.put(hasAccess,strResult);
            return m1;
        }else{
            hasAccess = true;
            strResult ='The case can be Re-Opened';
            m1.put(hasAccess,strResult);
            return m1;
        }
	}
    @AuraEnabled
    public static String reopenCase(string CaseId,string reason){
        string strResult = 'The Case has been Re-Opened';
        Case objcs                          = new Case(Id=CaseId);
        list<Case> existingCaseOrigin = [Select id, origin from Case where id=:CaseId];
        if(!existingCaseOrigin.isEmpty() ){
        	/*if(existingCaseOrigin[0].origin == 'CSC - Monitoring'){
        		objcs.OwnerId = label.CSC_Monitoring;
        	}else if(existingCaseOrigin[0].origin == 'CSC - RA'){
        		objcs.OwnerId = label.CSC_RA;
        	}else{*/
        		objcs.OwnerId = label.Client_Support_Centre_queue;
        	//}
        }
        objcs.comments                      ='Case Re-opening reason: ' + reason;
        objcs.CRM_Has_Unread_Comments__c        = true;
        objcs.CRM_Reason_for_case_re_opening__c = reason;
        objcs.CRM_Reopen_Additional_details__c  = 'The case has been re-opened by contact center agent.';
        objcs.Status                        = 'Re-Open';
        objcs.CRM_Update_counter__c             = 0;
        try{
            CaseTriggerHelper.OwnerChangeFromButton=false;
            update objcs;
        }catch(Exception e){
        	strResult = e.getMessage()+'';
        }
       return strResult;
    }
}