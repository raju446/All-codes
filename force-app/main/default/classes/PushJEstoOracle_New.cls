public class PushJEstoOracle_New 
{
    @Future(callout=true)
    public static void PushJEToOracle_Future(set<id> jhIds){
        PushJEToOracle(jhIds);        
    }
	public static void PushJEToOracle(set<id> jhIds)
	{
		try
		{
			//List<Journal_Entry__c> jeList 			= new List<Journal_Entry__c>();
			Set<Date> avaDate 							= BM_JournalEntryEngine.getActiveGLDates();
			map<id,list<Journal_Header__c>> jhRec 		= new map<id,list<Journal_Header__c>>();
			map<id,Address__c> addLst 					= new map<id,Address__c>();
			map<id,list<Journal_Entry__c>> jeList		= new map<id,list<Journal_Entry__c>>();
			map<id,Journal_Header__c> GLnotmatchedList 	= new map<id,Journal_Header__c>();
			map<id,string> transRefs					= new map<id,string>();
			map<id,string> appliedInvoiceNumbers		= new map<id,string>();
			map<id,string> receiptStatuses				= new map<id,string>();
			InsertJE_Class requestWrapper 				= new InsertJE_Class();
			set<id> JVIDs								= new set<id>();
			
			for(Journal_Header__c jhre : [Select Id, Name, Entity_Name__c, Fund_Transfer__c, Fund_Transfer__r.Name, Invoice__c, Invoice__r.Name, 
												Invoice_Line_Item__c, Invoice_Line_Item__r.Name, Invoice_Line_Item__r.Invoice__r.Name, 
												Receipt__c,Receipt__r.Payment_Method__c, Receipt__r.Name, 
                                          		Receipt__r.Bank_Detail_Configuration__r.Bank_Detail__c, 
												Refund__c, Refund__r.Name, Related_Invoice_Receipt__c, Related_Invoice_Receipt__r.Name, 
												Related_Invoice_Receipt__r.Invoice__r.Name, Transaction_Type__c,
												Receipt__r.Transaction_Reference__c,Receipt__r.Is_Reversed__c, Receipt__r.Reason__c, 
                                          		Oracle_InstanceId__c, Oracle_RequestId__c, Oracle_Status__c,Reference_Id__c, 
                                          		Reference_Name__c,Error_Message__c,  Receipt__r.Authorization_Code__c, 
                                          		Receipt__r.EFT_Reference_No__c, Receipt__r.Receipt_Reference__c,
												Account__c, Account__r.Tax_Registration_Number__c from Journal_Header__c where Id IN: jhIds 
												and Sync_Not_Required__c = false])
			{
				//1.
				if(jhRec.containsKey(jhre.Account__c)){
					jhRec.get(jhre.Account__c).add(jhre);
				}else{
					jhRec.put(jhre.Account__c, new list<Journal_Header__c>{jhre});
				}
				
				//2.
				String transRef = '';
				if(jhre.Receipt__r.Payment_Method__c != null)
				{
					if(jhre.Receipt__r.Payment_Method__c.contains('Card') && jhre.Receipt__r.Authorization_Code__c != null)
					{
						transRef = jhre.Receipt__r.Authorization_Code__c;
						//if([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox){ transRef = transRef+jhre.Receipt__r.Receipt_Reference__c; }
					} 
					else if(jhre.Receipt__r.Payment_Method__c == 'Electronic Funds Transfer' && jhre.Receipt__r.EFT_Reference_No__c != null)
					{ 
						transRef = jhre.Receipt__r.EFT_Reference_No__c;
					} 
					else{
						transRef = jhre.Receipt__r.Transaction_Reference__c;
					}
				}
				else { 
					transRef = jhre.Receipt__r.Transaction_Reference__c; 
				}
				transRefs.put(jhre.id,transRef);
				
				//3.
				String appliedInvoiceNumber = '';
				String receiptStatus 		= '';
				
				if((jhre.Transaction_Type__c == 'Adjustment' || jhre.Transaction_Type__c == 'Apply Credit Memo' || jhre.Transaction_Type__c == 'Unapply Credit Memo' || 			 jhre.Transaction_Type__c == 'Receipts-CM Application') && jhre.Invoice_Line_Item__c != null)
				{
					appliedInvoiceNumber = jhre.Invoice_Line_Item__r.Invoice__r.Name;
				} 
				else if(jhre.Transaction_Type__c=='Receipt Reversal'){
					receiptStatus = 'Reversed';
				}  
				else if((jhre.Transaction_Type__c=='Receipts-CM Application' || jhre.Transaction_Type__c=='Apply Receipt') && jhre.Related_Invoice_Receipt__c != null){
					appliedInvoiceNumber = jhre.Related_Invoice_Receipt__r.Invoice__r.Name; receiptStatus = 'Applied';
				}
				else if(jhre.Transaction_Type__c=='Unapply Receipt' && jhre.Related_Invoice_Receipt__c != null){
					receiptStatus = 'Unapplied';
				}
				appliedInvoiceNumbers.put(jhre.id,appliedInvoiceNumber);
				receiptStatuses.put(jhre.id,receiptStatus);
			}
			
			for(Address__c add : [Select Id, Entity__c, Country__c, State__c, Emirates__c from Address__c where Entity__c IN: jhRec.keyset() and Type__c='Physical' ]){
				addLst.put(add.Entity__c,add);
			}
			
			for(Journal_Entry__c je : [Select Id, Name, CreatedDate, Account__c, Account_Segment__c, Account_Segment_Description__c, 
                                       Balance_AED__c, Balance_OC__c, Code_Combination__c, Code_Combination_Description__c, 
										Conversion_Rate__c, Cost_center__c, Cost_center_Description__c, Credit_AED__c, Credit_OC__c, 
                                       	Currency__c, Debit_AED__c, Debit_OC__c, Entity__c, Entity_Description__c, Fund_Transfer__c, 
										Future2__c, Future2_Description__c, GL_Date__c, Inter_company__c, Inter_company_Description__c, 
                                       	Invoice__c, Credit_Memo_Application__c, Journal_Header__c, Journal_Header__r.Transaction_Type__c, 
										Journal_Header__r.Entity_Name__c, Program__c, Program_Description__c, Project__c, 
                                       	Project_Description__c, Receipt__c, Refund__c,  Related_Invoice_Receipt__c, Tax_Rate_Code__c,
                                        Journal_Header__r.Reference_Id__c, Journal_Header__r.Reference_Name__c, 
                                       	Journal_Entry_Line_Description__c, Journal_Header__r.Name, Journal_Header__r.Account__c, 
                                       	Journal_Header__r.Account__r.Id, Journal_Header__r.Account__r.Name,
                                        Journal_Header__r.Receipt__c, Journal_Header__r.Receipt__r.Is_Reversed__c, 
                                       	Journal_Header__r.Receipt__r.Reason__c, 
                                        Journal_Header__r.Receipt__r.Bank_Detail_Configuration__c, 
                                       	Journal_Header__r.Receipt__r.Bank_Detail_Configuration__r.Bank_Detail__c,
                                        Journal_Header__r.Account__r.Tax_Registration_Number__c,  
                                       	Journal_Header__r.Receipt__r.Payment_Method__c 
									FROM Journal_Entry__c where Journal_Header__c IN: jhIds])
			{
				if(!avaDate.contains(je.GL_Date__c))
				{
					Journal_Header__c jh = new Journal_Header__c(id=je.Journal_Header__c, Oracle_Status__c = 'Error',
													Error_Message__c = 'GL Period is not open for this GL Date: '+je.GL_Date__c);
					GLnotmatchedList.put(jh.id, jh);
					continue;
				}
				JVIDs.add(je.Journal_Header__c);
				if(jeList.containsKey(je.Journal_Header__c)){
					jeList.get(je.Journal_Header__c).add(je);
				}else{
					jeList.put(je.Journal_Header__c, new list<Journal_Entry__c>{je});
				}
			}
			
			requestWrapper.CreateGlJournals = new List<CreateGlJournals>();
			Integer i						= 00001;
			
            list<Journal_Entry__c> jelst = new list<Journal_Entry__c>();
            for(list<Journal_Entry__c> j : jeList.values()){
                jelst.addAll(j);
            }
            //jelst.addAll((list<Journal_Entry__c>)jeList.values());
			for(Journal_Entry__c je : jelst)
			{
                DateTime gldt 					= DateTime.newInstance(je.GL_Date__c.year(), je.GL_Date__c.month(),je.GL_Date__c.day());
                CreateGlJournals cj 			= new CreateGlJournals();
                cj.StatusCode 					= 'NEW';
                cj.LedgerId 					= System.Label.OracleLedgerId;//'300000008149083';
                cj.TransactionDate 				= gldt.format('yyyy-MM-dd');
                cj.Source 						= 'Bill ADGM';
                cj.Category 					= je.journal_header__r.Transaction_Type__c;
                cj.CurrencyCode 				= je.Currency__c;
                cj.CreationDate 				= je.CreatedDate.format('yyyy-MM-dd');
                cj.ActualFlag 					= 'A';
                cj.DebitAmount 					= String.valueOf(je.Debit_OC__c);
                cj.CreditAmount 				= String.valueOf(je.Credit_OC__c);
                cj.BatchName 					= je.Journal_Header__r.Name + ' |';
                cj.JournalEntryName 			= '';
                cj.JournalEntryLineDescription 	= je.Journal_Entry_Line_Description__c;
                cj.Segment1 					= je.Entity__c;
                cj.Segment2 					= je.Account_Segment__c;
                cj.Segment3 					= je.Cost_center__c;
                cj.Segment4 					= je.Project__c;
                cj.Segment5 					= je.Inter_company__c;
                cj.Segment6 					= je.Program__c;
                cj.Segment7 					= je.Future2__c;
                cj.sf_batch_id 						= je.Journal_Header__c;
                cj.CurrencyConversionType 		= 'Corporate';
                cj.CurrencyConversionDate 		= je.CreatedDate.format('yyyy-MM-dd');
                cj.CurrencyConversionRate 		= null;//String.valueOf((je.Currency__c == 'AED') ? 1 : je.Conversion_Rate__c);
                cj.SequenceNumber 				= String.valueOf(i);
				cj.AdditionalInformation 		= transRefs.get(je.Journal_Header__c);
                string attr1 					= je.Journal_Header__r.Account__r.Id +'|'+je.Journal_Header__r.Account__r.Name;
                
				if(addLst.containsKey(je.Journal_Header__r.Account__c)){
					Address__c addrec = addLst.get(je.Journal_Header__r.Account__c);
					attr1 = attr1 + '|' + addrec.Country__c + '|' + addrec.Emirates__c;
				}
				
                cj.Attribute1 					= attr1;
                cj.Attribute2 					= je.Journal_Header__r.Reference_Name__c;
				
				if(appliedInvoiceNumbers.containsKey(je.Journal_Header__c)){
					cj.Attribute3 				= appliedInvoiceNumbers.get(je.Journal_Header__c);
				}
                if(receiptStatuses.containsKey(je.Journal_Header__c)){
					cj.Attribute4 				= receiptStatuses.get(je.Journal_Header__c);//Receipt Status (Applied - Unapplied - Unidentified- Reversed)
				}
                
                cj.Attribute5 					= je.Account__c;
                cj.Attribute6 					= je.Journal_Header__r.Reference_Id__c;
                cj.Attribute7 					= (String.isNotBlank(je.Journal_Header__r.Receipt__c) && je.Journal_Header__r.Receipt__r.Is_Reversed__c) ? je.Journal_Header__r.Receipt__r.Reason__c : ''; 
                cj.Attribute8 					= (String.isNotBlank(je.Journal_Header__r.Receipt__c) && String.isNotBlank(je.Journal_Header__r.Receipt__r.Bank_Detail_Configuration__c)) ? 	je.Journal_Header__r.Receipt__r.Bank_Detail_Configuration__r.Bank_Detail__c : '';
                //Receipt bank account (That will be reference for CM reconciliation)
                //cj.Attribute9 = (String.isNotBlank(jhRec.Account__r.Tax_Registration_Number__c)) ? ('|'+jhRec.Account__r.Tax_Registration_Number__c) : '';//Tax Rate Code | Tax Registration Number
                cj.Attribute9 					= je.Tax_Rate_Code__c+'|'+je.Journal_Header__r.Account__r.Tax_Registration_Number__c;//Tax Rate Code | Tax Registration Number
                cj.Attribute10 					= (String.isNotBlank(je.Journal_Header__r.Receipt__c) && String.isNotBlank(je.Journal_Header__r.Receipt__r.Payment_Method__c)) ? je.Journal_Header__r.Receipt__r.Payment_Method__c : '';//Payment Method - Wire Transfer/Credit card etc…
                cj.reconciliationReference 		= transRefs.get(je.Journal_Header__c);
                i++;
                requestWrapper.CreateGlJournals.add(cj);
            }
			
			String sInputValue = JSON.serialize(requestWrapper);
			system.debug('sInputValue==>>' + sInputValue);
			Http http 				= new Http();
            HttpRequest request 	= new HttpRequest();
            request.setEndpoint('callout:FusionCloud/XXADG_REST_FUSIO_CREAT_GL_JOURN/1.0/');
            request.setMethod('POST');
            request.setTimeout(120000);
            request.setHeader('content-type','application/json');
            request.setBody(sInputValue);
            HTTPResponse objHTTPResponse = http.send(request);
            system.debug('objHTTPResponse--->'+objHTTPResponse);
            system.debug('objHTTPResponse Body--->'+objHTTPResponse.getBody());
                   
            //save Payload on fail for reference purpose
            //JEsStatusFromOracle.savePayload('FusionCloud/XXADG_REST_FUSIO_CREAT_GL_JOURN/1.0/',sInputValue,jhId,objHTTPResponse.getBody(),jhRec.Reference_Id__c);
            JEsStatusFromOracle.savePayload('FusionCloud/XXADG_REST_FUSIO_CREAT_GL_JOURN/1.0/',sInputValue,null,objHTTPResponse.getBody(),null);
            
            OutputParameters outWrap = (OutputParameters)JSON.deserialize(objHTTPResponse.getBody(), OutputParameters.class);
            system.debug('outWrap--->'+outWrap);
			
            if(outWrap != null){
                //update jhRec;
				list<Journal_Header__c> updteJHlst = new list<Journal_Header__c>();
				for(list<Journal_Header__c> jh : jhRec.values())
                {
                    for(Journal_Header__c j : jh){
                        if(JVIDs.contains(j.id)){
                            j.Oracle_InstanceId__c = outWrap.InstanceId; j.Oracle_RequestId__c = outWrap.RequestId; j.Oracle_Status__c = outWrap.Status; j.Error_Message__c = outWrap.ErrorMessage;
                            updteJHlst.add(j);
						}
                    }
				}
				if(!updteJHlst.isEmpty()){
					update updteJHlst;
				}
            }
			
			//execute at last.
			if(!GLnotmatchedList.isEmpty()){
				update GLnotmatchedList.values();
			}

		}catch(Exception ex){
            system.debug(ex.getMessage());
            system.debug(ex.getLineNumber());
            Log__c objLog = new Log__c(Line_Number__c = ex.getLineNumber(),Stack_Trace__c =  ex.getStackTraceString(),Type_Name__c = ex.getTypeName(),User_Email__c = UserInfo.getUserEmail());
            objLog.Message__c = ex.getMessage().length() > 250 ? ex.getMessage().substring(0,250) : ex.getMessage();
            insert objLog;
        }
	}
	
	
	public Class InsertJE_Class{
        public List<CreateGlJournals> CreateGlJournals;    
    }
    
    public class CreateGlJournals{
        public string StatusCode;
        public string LedgerId;
        public string TransactionDate;
        public string Source; //New Field to pass source system name
        public string Category;
        public string CurrencyCode;
        public string CreationDate;
        public string ActualFlag;
        public string DebitAmount;
        public string CreditAmount;
        public string BatchName;
        public string JournalEntryName;
        public string JournalEntryLineDescription;
        public string Segment1;
        public string Segment2;
        public string Segment3;
        public string Segment4;
        public string Segment5;
        public string Segment6;
        public string Segment7;
        public string CurrencyConversionType;
        public string CurrencyConversionDate;
        public string CurrencyConversionRate;
        public string SequenceNumber;
        public string AdditionalInformation;
        public string Attribute1;
        public string Attribute2;
        public string Attribute3;
        public string Attribute4;
        public string Attribute5;
        public string Attribute6;
        public string Attribute7;
        public string Attribute8;
        public string Attribute9;
        public string Attribute10;
        public string sf_batch_id;
        public string reconciliationReference;        
    }
    
    public class OutputParameters{
        public string RequestId;
        public string Status;
        public string InstanceId;
        public string ErrorMessage;
    }
}