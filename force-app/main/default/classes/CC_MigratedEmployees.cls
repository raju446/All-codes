/*
    Author      : Azmath
    Date        : 20-Dec-2018
    Description : Custom code to generate Work Permit Number.
    --------------------------------------------------------------------------------------
*/
global without sharing class CC_MigratedEmployees implements HexaBPM.iCustomCodeExecutable
{
	global string EvaluateCustomCode(HexaBPM__Service_Request__c SR, HexaBPM__Step__c step)
	{
		string strResult = 'Success';
		Id nationaltiyId;
		if(step.HexaBPM__SR__c != null)
		{
			try{	
				HexaBPM__Status__c stepstat = [SELECT HexaBPM__Code__c FROM HexaBPM__Status__c WHERE ID=:step.HexaBPM__Status__c];
				system.debug('======'+stepstat.HexaBPM__Code__c);
				HexaBPM__Service_Request__c objSR;
				if(stepstat.HexaBPM__Code__c == 'APPLICATION_VERIFIED')
				{
					//1.Update work permit number..
					Integer adgmPermanentWorkPermit;
					List<Work_Permit_Running_Number__c> workPermitList 	= new List<Work_Permit_Running_Number__c>();
					Work_Permit_Running_Number__c permaWorkPermit 		= Work_Permit_Running_Number__c.getInstance('Permanent Work Permit');
					adgmPermanentWorkPermit 							= Integer.valueOf(permaWorkPermit.Work_Permit_Running_Number__c);
					permaWorkPermit.Work_Permit_Running_Number__c 		= ++adgmPermanentWorkPermit;
		            workPermitList.add(permaWorkPermit);
		            update workPermitList;
		            
		            //2. Update Work permit detais on SR to generate the work permit..
		            Contact con = [Select id,Accountid,FirstName,LastName,Passport_No__c,Nationality_Lookup__c,Nationality__c,First_Name_Arabic__c,Last_Name_Arabic__c
	            				 FROM Contact where Id=:step.HexaBPM__SR__r.HexaBPM__Contact__c];
					objSR 								= new HexaBPM__Service_Request__c(Id = step.HexaBPM__SR__c);
					objSR.Work_Permit_Card_Number__c 	= permaWorkPermit.Work_Permit_Number_Prefix__c + String.valueOf(adgmPermanentWorkPermit).leftpad(7).replace(' ', '0');
		            //objSR.Residence_Visa_Number__c		= step.HexaBPM__SR__r.Passport_Number__c;
		            objSR.First_Name__c 				= con.FirstName;
		            objSR.Last_Name__c 					= con.LastName;
		            objSR.First_Name_Arabic__c 			= con.First_Name_Arabic__c;
		            objSR.Last_Name_Arabic__c 			= con.Last_Name_Arabic__c;
		            if(con.Nationality_Lookup__c == null)
	            	{
	            		list<Lookup__c> nationality = [Select id FROM Lookup__c where Name=:con.Nationality__c and Type__c='Nationality'];
		            	if(!nationality.isEmpty()){
		            		objSR.Nationality_Lookup__c = nationality[0].id;
		            		con.Nationality_Lookup__c = nationality[0].id;
		            		nationaltiyId = nationality[0].id;
		            	}
	            	}
		            update objSR;
				}
				
				//Update work permit details and Create document detail in contact upon approval of work permit..
				else if(stepstat.HexaBPM__Code__c == 'APPROVED')
				{
					Contact con = [Select id,Accountid,FirstName,LastName,Passport_No__c,Nationality_Lookup__c,Nationality__c,First_Name_Arabic__c,Last_Name_Arabic__c
	            				 FROM Contact where Id=:step.HexaBPM__SR__r.HexaBPM__Contact__c];
	            				 
	            	con.Work_Permit_Card_Number__c 	= step.HexaBPM__SR__r.Work_Permit_Card_Number__c;
	            	con.Work_Permit_Issue_Date__c 	= step.HexaBPM__SR__r.Work_Permit_Issue_Date__c;
	            	con.Work_Permit_Expiry_Date__c 	= step.HexaBPM__SR__r.Work_Permit_Expiry_Date__c;
	            	con.Residence_Visa_Number__c	= step.HexaBPM__SR__r.Residence_Visa_Number__c;
	            	//con.Passport_No__c 				= step.HexaBPM__SR__r.Passport_Number__c;
		            con.Nationality_Lookup__c 		= step.HexaBPM__SR__r.Nationality_Lookup__c;
		            con.Unified_ID_No__c			= step.HexaBPM__SR__r.Unified_ID_No__c;
	            	update con;
	            	
	            	Document_Details__c docs 		= new Document_Details__c();  
			        docs.RecordTypeId				= UtilityHelper.getDocumentDetailRecordtypeId('Employee_Work_Permit');
			        docs.Document_Status__c			= 'Active';
			        docs.Document_Type__c			= 'Employee Work Permit';
			        docs.Document_Issue_Date__c		= con.Work_Permit_Issue_Date__c;
			        docs.Document_Expiry_Date__c	= con.Work_Permit_Expiry_Date__c;
			        docs.Account__c					= con.Accountid;
			        docs.Contact__c					= con.id; 
			        insert docs;
				}
            } 
            catch(Exception e){
                    strResult = e.getMessage();
            }
		}
		return strResult;
	}
}