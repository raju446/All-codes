/*
    Author      : Durga Prasad
    Date        : 06-May-2020
    Description : Trigger helper for RA_Receipt_Invoice_TriggerHandler.
    ---------------------------------------------------------------------
*/
public without sharing class RA_Receipt_Invoice_TriggerHelper {
    public static void PopulateAccount(list<RA_Receipt_Invoice__c> TriggerNew){
        set<string> entityNos = new set<string>();
        set<string> entityNames = new set<string>();
        for(RA_Receipt_Invoice__c RARI : TriggerNew){
        	
        	if(RARI.Account__c==null){
	        	if(RARI.Entity_Number__c!=null)
	            	entityNos.add(RARI.Entity_Number__c);
	            if(RARI.Entity_Name__c!=null)
	            	entityNames.add(RARI.Entity_Name__c);
        	}
        }
        map<string,string> MapAccountIds = new map<string,string>();
        if(entityNos.size()>0 && entityNames.size()>0){
        	for(Account acc:[Select Id,Name,Entity_Id__c from Account where (Entity_Id__c IN:entityNos or Name IN:entityNames) and RecordType.DeveloperName='ADGM_Registered_Company']){
        		MapAccountIds.put(acc.Name.tolowercase(),acc.Id);
        		if(acc.Entity_Id__c!=null)
        			MapAccountIds.put(acc.Entity_Id__c,acc.Id);
        	}
        }
        list<Account> lstAccountsTBI = new list<Account>();
        map<string,Account> MapAccountsTBI = new map<string,Account>();
        string recordTypeId;
        for(Recordtype rt:[select Id from RecordType where sObjectType='Account' and DeveloperName='ADGM_Registered_Company']){
    		recordTypeId = rt.Id;
    	}
        for(RA_Receipt_Invoice__c RARI : TriggerNew){
        	if(RARI.Receipt_Date__c!=null){
	        	if(RARI.Account__c==null){
		            if(RARI.Entity_Number__c!=null && MapAccountIds.get(RARI.Entity_Number__c)!=null){
		            	RARI.Account__c = MapAccountIds.get(RARI.Entity_Number__c);
		            }else if(RARI.Entity_Name__c!=null && MapAccountIds.get(RARI.Entity_Name__c.tolowercase())!=null){
		            	RARI.Account__c = MapAccountIds.get(RARI.Entity_Name__c.tolowercase());
		            }else{
		            	string AccountKey = '';
		            	if(RARI.Entity_Number__c!=null)
		            		AccountKey = RARI.Entity_Number__c;
		            	else if(RARI.Entity_Name__c!=null)
		            		AccountKey = RARI.Entity_Name__c;
		            		
		            	if(AccountKey!='' && MapAccountsTBI.get(AccountKey)==null){
			            	Account objAcc = new Account();
			            	objAcc.Name = RARI.Entity_Name__c;
			            	objAcc.RecordTypeId = recordTypeId;
			                objAcc.Source_System_Id__c = RARI.Entity_Number__c;
			                objAcc.Is_Manually_Created__c = true;
			                objAcc.Source_System_Name__c = 'RA';
			                objAcc.Source_System__c = 'Catalyst';
			                objAcc.Entity_Status__c = 'Active';
			                objAcc.Entity_Id__c = RARI.Entity_Number__c;
			                if(RARI.Entity_Number__c!=null)
			                	MapAccountsTBI.put(RARI.Entity_Number__c,objAcc);
			                else
			                	MapAccountsTBI.put(RARI.Entity_Name__c,objAcc);
		            	}
		            }
	        	}
        	}
        }
        map<string,string> MapInsertedAccounts = new map<string,string>();
        if(MapAccountsTBI.size()>0){
        	Schema.SObjectField UpsertFld = Account.Fields.Source_System_Id__c;
	       	//list<Database.UpsertResult> UpsertResultLst = Database.upsert(lstDyncObject,UpsertFld,false);
	        list<Database.UpsertResult> srList = Database.upsert(MapAccountsTBI.values(),UpsertFld,false);
			set<string> setAccountIds = new set<string>();	        
	        if(srList!=null){
	        	for(Database.UpsertResult sr : srList){
	                if(sr.isSuccess())
	                    setAccountIds.add(sr.getId());
	           	}
	        }
	        for(Account acc:[Select Id,Name,Source_System_Id__c from Account where Id IN:setAccountIds]){
	        	MapInsertedAccounts.put(acc.Name,acc.Id);
	        	if(acc.Source_System_Id__c!=null)
	        		MapInsertedAccounts.put(acc.Source_System_Id__c,acc.Id);
	        }
        }
        //insert MapAccountsTBI.values();
        for(RA_Receipt_Invoice__c RARI : TriggerNew){
        	if(RARI.Account__c==null){
	            if(RARI.Entity_Number__c!=null && MapAccountIds.get(RARI.Entity_Number__c)!=null){
	            	RARI.Account__c = MapAccountIds.get(RARI.Entity_Number__c);
	            }else if(RARI.Entity_Name__c!=null && MapAccountIds.get(RARI.Entity_Name__c.tolowercase())!=null){
	            	RARI.Account__c = MapAccountIds.get(RARI.Entity_Name__c.tolowercase());
	            }else{
	            	if(RARI.Entity_Number__c!=null && MapInsertedAccounts.get(RARI.Entity_Number__c)!=null){
		            	RARI.Account__c = MapInsertedAccounts.get(RARI.Entity_Number__c);
		            }else if(RARI.Entity_Name__c!=null && MapInsertedAccounts.get(RARI.Entity_Name__c)!=null){
		            	RARI.Account__c = MapInsertedAccounts.get(RARI.Entity_Name__c);
		            }
	            }
        	}
        }
    }
    public static void Create_Receipt_Invoice(list<RA_Receipt_Invoice__c> TriggerNew){
    	try{
			list<RA_Receipt_Invoice__c> lstRI = new list<RA_Receipt_Invoice__c>();
			map<string,Invoice__c> MapInvoices = new map<string,Invoice__c>();
	    	list<Invoice_Line_Item__c> lstlineItems = new list<Invoice_Line_Item__c>();
	    	map<string,Receipt__c> MapReceipts = new map<string,Receipt__c>();
	    	
	    	set<string> setReceiptNumbers = new set<string>();
	    	for(RA_Receipt_Invoice__c RARI:TriggerNew){
	    		if(RARI.Receipt_Number__c!=null)
	    			setReceiptNumbers.add(RARI.Receipt_Number__c);
	    	}
	    	map<string,string> MapExistingReceipts = new map<string,string>();
	    	if(setReceiptNumbers.size()>0){
	    		for(Invoice__c inv:[Select Id,Source_Invoice_Id__c from Invoice__c where Source_Invoice_Id__c IN:setReceiptNumbers]){
	    			MapExistingReceipts.put(inv.Source_Invoice_Id__c,inv.Id);
	    		}
	    	}
	    	
	    	for(RA_Receipt_Invoice__c RARI:TriggerNew){
	    		if(RARI.Receipt_Date__c!=null && RARI.Receipt_Number__c!=null && MapExistingReceipts.get(RARI.Receipt_Number__c)==null){
		    		Invoice__c invObj = new Invoice__c();
		    		invObj.Is_Source_Invoice__c = true;
		    		invObj.Source_System__c = 'Catalyst';
		            invObj.Source_Invoice_Id__c = RARI.Receipt_Number__c;//RARI.Payment_ID__c;
		            invObj.Description__c = RARI.Fee_Description__c;
		            if(RARI.Account__c!=null)
		        		invObj.Entity__c = RARI.Account__c;
		            
		            invObj.RA_Receipt_Invoice__c = RARI.Id;
		            invObj.Oracle_Invoice_Type__c = 'RA Invoice';
		            invObj.Invoice_Date__c = RARI.Receipt_Date__c;
		            invObj.GL_Date__c = RARI.Receipt_Date__c;
		            invObj.Payment_Term__c = 'Immediate';
		            invObj.Payment_Currency__c = 'USD';
		            invObj.Status__c = 'Success';
		            invObj.Transaction_Type__c = 'NonWallet';
		            invObj.Invoice_Class__c = 'Invoice';
		            invObj.Is_Created_Manually__c = true;
		            invObj.From_Data_Migration__c = false;
		            MapInvoices.put(RARI.Id,invObj);
		            
		    		if(RARI.Payment_Method__c!='Waive Fees' && RARI.Payment_Method__c!='Electronic Funds Transfer (direct credit)' && RARI.Payment_Method__c!='Other' && RARI.Payment_Method__c!='Point of Sale'){// && RARI.Payment_Method__c!='Other'
			    		
			    		Receipt__c receiptObj = new Receipt__c();
			    		if(RARI.Account__c!=null)
		        			receiptObj.Entity__c = RARI.Account__c;
		            	
			    		receiptObj.Source_System_1__c = 'Catalyst';
				        if(RARI.Receipt_Number__c!=null)
				        	receiptObj.Source_Receipt_Id__c = RARI.Receipt_Number__c;
				        else
				        	receiptObj.Source_Receipt_Id__c = RARI.Id;
				        receiptObj.RA_Receipt_Invoice__c = RARI.Id;
						receiptObj.Amount__c = RARI.Total_Paid_in_USD__c;
						receiptObj.GL_Date__c = RARI.Receipt_Date__c;
						receiptObj.Payment_Method__c = RARI.Payment_Method__c;
						if(RARI.Payment_ID__c!=null)
							receiptObj.Transaction_Reference__c = RARI.Payment_ID__c+'-'+RARI.Id;
						else
							receiptObj.Transaction_Reference__c = RARI.Id;
						receiptObj.Receipt_Date__c = RARI.Receipt_Date__c;
						receiptObj.Description__c = RARI.Fee_Description__c;
						receiptObj.Payment_Purpose_Text__c = '';
						receiptObj.Payment_Currency__c = 'USD';
						receiptObj.Status__c = 'Success';
						receiptObj.Transaction_Type__c = 'NonWallet';
						receiptObj.Is_Created_Manually__c = true;
						receiptObj.From_Data_Migration__c = false;//To be removed after one month data migration
						MapReceipts.put(RARI.Id,receiptObj);
		    		}
	    		}
	    	}
	    	
	    	if(MapInvoices.size()>0)
	    		insert MapInvoices.values();
	    	
	    	if(MapReceipts.size()>0)
	    		insert MapReceipts.values();
	    	
	    	list<Related_Invoice_Receipt__c> lstInvoiceReceiptJunction = new list<Related_Invoice_Receipt__c>();
	    	for(RA_Receipt_Invoice__c RARI:TriggerNew){
	    		if(MapReceipts.get(RARI.Id)!=null && MapReceipts.get(RARI.Id).Id!=NULL && MapInvoices.get(RARI.Id)!=null && MapInvoices.get(RARI.Id).Id!=NULL){
	    			Related_Invoice_Receipt__c objJun = new Related_Invoice_Receipt__c();
                    objJun.Applied__c = true;
	    			objJun.Invoice__c = MapInvoices.get(RARI.Id).Id;
	    			objJun.Receipt__c = MapReceipts.get(RARI.Id).Id;
	    			objJun.Direction__c = 'From Receipt To Invoice';
	    			objJun.Amount_Applied__c = RARI.Total_Paid_in_USD__c;
                    objJun.ORACLE_Applied_Amount__c = RARI.Total_Paid_in_USD__c;
                    objJun.Oracle_Converted_Applied_Amount__c= RARI.Total_Paid_in_USD__c * 3.6725;
                    objJun.Oracle_Converted_UnApplied_Amount__c = 0;
	    			objJun.Applied_Date__c = RARI.Receipt_Date__c;
	    			objJun.RA_Receipt_Invoice__c = RARI.Id;
	    			lstInvoiceReceiptJunction.add(objJun);
	    		}
	    	}
	    	if(lstInvoiceReceiptJunction.size()>0)
	        	insert lstInvoiceReceiptJunction;
	    	
	    	map<string,RA_Receipt_Invoice__c> MapRITBU = new map<string,RA_Receipt_Invoice__c>();
	    	for(Invoice__c Inv:MapInvoices.values()){
	    		if(Inv.RA_Receipt_Invoice__c!=null)
	    			MapRITBU.put(Inv.RA_Receipt_Invoice__c,new RA_Receipt_Invoice__c(Id=Inv.RA_Receipt_Invoice__c,Invoice__c=Inv.Id));
	    	}
	    	for(Receipt__c rcpt:MapReceipts.values()){
	    		if(rcpt.RA_Receipt_Invoice__c!=null && MapRITBU.get(rcpt.RA_Receipt_Invoice__c)!=null){
	    			RA_Receipt_Invoice__c objRARI = MapRITBU.get(rcpt.RA_Receipt_Invoice__c);
	    			objRARI.Receipt__c = rcpt.Id;
	    			MapRITBU.put(rcpt.RA_Receipt_Invoice__c,objRARI);
	    		}
	    	}
	    	
	    	if(MapRITBU.size()>0)
	    		update MapRITBU.values();
    	}catch(Exception e){
    		string sMessage = e.getMessage()+'';
    		Log__c objLog = new Log__c(Line_Number__c = e.getLineNumber(),Additional_Information__c = sMessage,Stack_Trace__c =  e.getStackTraceString(),Type_Name__c = e.getTypeName());
            if(sMessage .length() > 240) 
                objLog.Message__c = sMessage.subString(0,240);
            else 
                objLog.Message__c = sMessage;
            insert objLog;
    	}
    }
}