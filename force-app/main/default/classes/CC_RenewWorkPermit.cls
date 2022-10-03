global without sharing class CC_RenewWorkPermit implements HexaBPM.iCustomCodeExecutable{
    global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step) { 
        string strResult = 'Success';
        try{
	        if(step.HexaBPM__SR__c !=null && step.HexaBPM__SR__r.HexaBPM__Contact__c !=null && step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Employee_Work_Permit_UAE_GCC_National_Renew'){
	            list<Contact> conlist = [SELECT Work_Permit_Expiry_Date__c FROM Contact WHERE Id=:step.HexaBPM__SR__r.HexaBPM__Contact__c limit 1];
	            if(!conlist.isEmpty()){
	                conlist[0].Work_Permit_Expiry_Date__c = step.HexaBPM__SR__r.Work_Permit_Expiry_Date__c;
	                conlist[0].Passport_Expiry_Date__c = step.HexaBPM__SR__r.Passport_Expiry_Date__c;
	                update conlist;
	                
	                list<Document_Details__c> docDetails = [Select id from Document_Details__c 
	                                        where Document_Type__c = 'Employee Work Permit(UAE/GCC National)' 
	                                        AND Contact__c = :conlist[0].id limit 1];
	                if(!docDetails.isEmpty()){
	                    docDetails[0].Document_Expiry_Date__c = step.HexaBPM__SR__r.Work_Permit_Expiry_Date__c;
	                    docDetails[0].Document_Last_Renewed_Date__c = step.HexaBPM__SR__r.Work_Permit_Issue_Date__c;
	                    update docDetails;
	                }
	            }
	        }
	        if(step.HexaBPM__SR__c !=null && step.HexaBPM__SR__r.HexaBPM__Contact__c !=null && step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Temporary_Work_Permit_Renew'){
	            list<Contact> conlist = [SELECT Work_Permit_Expiry_Date__c FROM Contact WHERE Id=:step.HexaBPM__SR__r.HexaBPM__Contact__c limit 1];
	            if(!conlist.isEmpty()){
	                conlist[0].Work_Permit_Expiry_Date__c = step.HexaBPM__SR__r.Work_Permit_Expiry_Date__c;
	                conlist[0].Residence_Visa_Number__c = step.HexaBPM__SR__r.Residence_Visa_Number__c;
	                conlist[0].Residence_Visa_Date_of_Expiry__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;
	                conlist[0].Residence_Visa_Date_of_Issue__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c;
	                update conlist;
	                
	                list<Document_Details__c> docDetails = [Select id from Document_Details__c 
	                                        where Document_Type__c = 'Temporary Employee Work Permit' 
	                                        AND Contact__c = :conlist[0].id limit 1];
	                if(!docDetails.isEmpty()){
	                    docDetails[0].Document_Expiry_Date__c = step.HexaBPM__SR__r.Work_Permit_Expiry_Date__c;
	                    docDetails[0].Document_Last_Renewed_Date__c = step.HexaBPM__SR__r.Work_Permit_Issue_Date__c;
	                    update docDetails;
	                }
	            }
	        }
	        /*
	        The below condition will be executed upon residence visa approved. 
	        Once approved, we need to update contacts work permit exp date, wp number(if not isssued).
	        Also, populate SRs work permit Number(from contact), wp exp date(visa exp date from SR) to generate the WP document using DDP.
	        */
	        if(step.HexaBPM__SR__r.HexaBPM__Record_Type_Name__c == 'Employment_Visa_Renewal' && step.HexaBPM__SR__r.HexaBPM__Contact__c!=null){
	        	HexaBPM__Service_Request__c  srv = new HexaBPM__Service_Request__c();
	            srv.id = step.HexaBPM__SR__c;
	            
	        	Integer adgmPermanentWorkPermit;
	            string EmployeeWorkPermitNumber;
	            for(Contact objCon:[Select Id,Work_Permit_Card_Number__c from Contact where Id=:step.HexaBPM__SR__r.HexaBPM__Contact__c and RecordType.DeveloperName='Contact_Employee']){
	            	if(objCon.Work_Permit_Card_Number__c!=null)
	            		EmployeeWorkPermitNumber = objCon.Work_Permit_Card_Number__c;
	            }
	            Contact objCon = new Contact(Id=step.HexaBPM__SR__r.HexaBPM__Contact__c);
	            if(EmployeeWorkPermitNumber==null){
		            Work_Permit_Running_Number__c permaWorkPermit = Work_Permit_Running_Number__c.getInstance('Permanent Work Permit');
		            adgmPermanentWorkPermit = Integer.valueOf(permaWorkPermit.Work_Permit_Running_Number__c);
		            string NewWorkPPermitNumber = permaWorkPermit.Work_Permit_Number_Prefix__c + String.valueOf(++adgmPermanentWorkPermit).leftpad(7).replace(' ', '0');
	            	
	            	objCon.Work_Permit_Card_Number__c = NewWorkPPermitNumber;
	            	if(step.HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c!=null)
	            		objCon.Work_Permit_Issue_Date__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c;
	            	if(step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c!=null)
	            		objCon.Work_Permit_Expiry_Date__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;
	            	
	            	srv.Work_Permit_Card_Number__c = NewWorkPPermitNumber;
	            }else{
	            	if(step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c!=null)
	            		objCon.Work_Permit_Expiry_Date__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;
	            	srv.Work_Permit_Card_Number__c = EmployeeWorkPermitNumber;
	            }
	            update objCon;
	            
	            srv.Work_Permit_Issue_Date__c   = step.HexaBPM__SR__r.Residence_Visa_Date_of_Issue__c;
	            srv.Work_Permit_Expiry_Date__c = step.HexaBPM__SR__r.Residence_Visa_Date_of_Expiry__c;
	            update srv;
	            system.debug('=========='+sr);
	        }
        }catch(Exception e){
    		strResult = e.getMessage()+'';
            system.debug('======='+e.getMessage());
    	}
        return strResult;
    }
}