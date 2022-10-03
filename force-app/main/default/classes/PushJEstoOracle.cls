public class PushJEstoOracle {
    
    @Future(callout=true)
    public static void PushJEToOracle_Future(string jhId){
        PushJEToOracle(jhId);        
    }
    
    public static void PushJEToOracle(string jhId){
        try{
            List<Journal_Entry__c> jeList = new List<Journal_Entry__c>();
            Set<Date> avaDate = BM_JournalEntryEngine.getActiveGLDates();
            Journal_Header__c jhRec = [Select Id, Name, Entity_Name__c, Fund_Transfer__c, Fund_Transfer__r.Name, Invoice__c, Invoice__r.Name, Invoice_Line_Item__c, Invoice_Line_Item__r.Name, 
                                       Invoice_Line_Item__r.Invoice__r.Name, Receipt__c,Receipt__r.Payment_Method__c,Receipt__r.Name, Receipt__r.Bank_Detail_Configuration__r.Bank_Detail__c, 
                                       Refund__c, Refund__r.Name, Related_Invoice_Receipt__c, Related_Invoice_Receipt__r.Name, Related_Invoice_Receipt__r.Invoice__r.Name, Transaction_Type__c,
                                       Receipt__r.Transaction_Reference__c,Receipt__r.Is_Reversed__c, Receipt__r.Reason__c, Oracle_InstanceId__c, Oracle_RequestId__c, Oracle_Status__c,Reference_Id__c,
                                       Reference_Name__c,Error_Message__c,Receipt__r.Authorization_Code__c,Receipt__r.EFT_Reference_No__c,Receipt__r.Receipt_Reference__c,
                                       Account__c,Account__r.Tax_Registration_Number__c from Journal_Header__c where Id =: jhId LIMIT 1];
            
            List<Address__c> addLst = [Select Id,Country__c,State__c,Emirates__c from Address__c where Entity__c =: jhRec.Account__c LIMIT 1];
            
            
            jeList = [Select Id, Name, CreatedDate, Account__c, Account_Segment__c, Account_Segment_Description__c, Balance_AED__c, Balance_OC__c, Code_Combination__c, Code_Combination_Description__c, 
                      Conversion_Rate__c, Cost_center__c, Cost_center_Description__c, Credit_AED__c, Credit_OC__c, Currency__c, Debit_AED__c, Debit_OC__c, Entity__c, Entity_Description__c, Fund_Transfer__c, 
                      Future2__c, Future2_Description__c, GL_Date__c, Inter_company__c, Inter_company_Description__c, Invoice__c, Credit_Memo_Application__c, Journal_Header__c, Journal_Header__r.Transaction_Type__c, 
                      Journal_Header__r.Entity_Name__c, Program__c, Program_Description__c, Project__c, Project_Description__c, Receipt__c, Refund__c, Related_Invoice_Receipt__c,Tax_Rate_Code__c,
                      Journal_Header__r.Reference_Id__c,Journal_Header__r.Reference_Name__c,Journal_Header__r.Name,Journal_Header__r.Account__c,Journal_Header__r.Account__r.Id,Journal_Header__r.Account__r.Name 
                      from Journal_Entry__c where Journal_Header__c =: jhId];
            //List<CreateGlJournals> jList = new List<CreateGlJournals>();
            system.debug('jeList[0]==>>' + jeList[0]);
            system.debug('jeList[0]==>>' + jeList[0].GL_Date__c);
            if(!avaDate.contains(jeList[0].GL_Date__c)){
                jhRec.Oracle_Status__c = 'Error'; jhRec.Error_Message__c = 'GL Period is not open for this GL Date: '+jeList[0].GL_Date__c;
                update jhRec;
                Return;
            }
            
            String transRef = '';
            if(jhRec.Receipt__r.Payment_Method__c != null){
                if(jhRec.Receipt__r.Payment_Method__c.contains('Card') && jhRec.Receipt__r.Authorization_Code__c != null){
                    transRef = jhRec.Receipt__r.Authorization_Code__c;
                    if([SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox){ transRef = transRef+jhRec.Receipt__r.Receipt_Reference__c; }
                } 
                else if(jhRec.Receipt__r.Payment_Method__c == 'Electronic Funds Transfer' && jhRec.Receipt__r.EFT_Reference_No__c != null){ transRef = jhRec.Receipt__r.EFT_Reference_No__c;} 
                else { transRef = jhRec.Receipt__r.Transaction_Reference__c; }
            }
            else { transRef = jhRec.Receipt__r.Transaction_Reference__c; }
            
            InsertJE_Class requestWrapper = new  InsertJE_Class();
            requestWrapper.CreateGlJournals = new List<CreateGlJournals>();
            Integer i=00001;
            String appliedInvoiceNumber = '';
            String receiptStatus = '';
            if((jhRec.Transaction_Type__c=='Adjustment' || jhRec.Transaction_Type__c=='Apply Credit Memo' || jhRec.Transaction_Type__c=='Unapply Credit Memo' || jhRec.Transaction_Type__c=='Receipts-CM Application') && jhRec.Invoice_Line_Item__c != null){
                appliedInvoiceNumber = jhRec.Invoice_Line_Item__r.Invoice__r.Name;
            } 
            else if(jhRec.Transaction_Type__c=='Receipt Reversal'){ receiptStatus = 'Reversed';
            }  
            else if((jhRec.Transaction_Type__c=='Receipts-CM Application' || jhRec.Transaction_Type__c=='Apply Receipt') && jhRec.Related_Invoice_Receipt__c != null){
                appliedInvoiceNumber = jhRec.Related_Invoice_Receipt__r.Invoice__r.Name; receiptStatus = 'Applied';
            }
            else if(jhRec.Transaction_Type__c=='Unapply Receipt' && jhRec.Related_Invoice_Receipt__c != null){ receiptStatus = 'Unapplied';
            }
            else{
            }
            
            for(Journal_Entry__c je : jeList){
                DateTime gldt = DateTime.newInstance(je.GL_Date__c.year(), je.GL_Date__c.month(),je.GL_Date__c.day());
                CreateGlJournals cj = new CreateGlJournals();
                cj.StatusCode = 'NEW';
                cj.LedgerId = System.Label.OracleLedgerId;//'300000008149083';
                cj.TransactionDate = gldt.format('yyyy-MM-dd');
                cj.Source = 'Bill ADGM';
                cj.Category = je.journal_header__r.Transaction_Type__c;
                cj.CurrencyCode = je.Currency__c;
                cj.CreationDate = je.CreatedDate.format('yyyy-MM-dd');
                cj.ActualFlag = 'A';
                cj.DebitAmount = String.valueOf(je.Debit_OC__c);
                cj.CreditAmount = String.valueOf(je.Credit_OC__c);
                cj.BatchName = je.Journal_Header__r.Name;
                cj.JournalEntryName = '';
                cj.JournalEntryLineDescription = je.Code_Combination_Description__c;
                cj.Segment1 = je.Entity__c;
                cj.Segment2 = je.Account_Segment__c;
                cj.Segment3 = je.Cost_center__c;
                cj.Segment4 = je.Project__c;
                cj.Segment5 = je.Inter_company__c;
                cj.Segment6 = je.Program__c;
                cj.Segment7 = je.Future2__c;
                cj.CurrencyConversionType = 'Corporate';
                cj.CurrencyConversionDate = je.CreatedDate.format('yyyy-MM-dd');
                cj.CurrencyConversionRate = String.valueOf((je.Currency__c == 'AED') ? 1 : je.Conversion_Rate__c);
                cj.SequenceNumber = String.valueOf(i);
                cj.AdditionalInformation = transref;
                string attr1 = je.Journal_Header__r.Account__r.Id +'|'+je.Journal_Header__r.Account__r.Name;
                if(!addLst.isEmpty()){
                   attr1 = attr1 + '|' + addLst[0].Country__c + '|' + addLst[0].Emirates__c;
                }
                cj.Attribute1 = attr1;
                cj.Attribute2 = je.Journal_Header__r.Reference_Name__c;
                cj.Attribute3 = appliedInvoiceNumber;
                cj.Attribute4 = receiptStatus;//Receipt Status (Applied - Unapplied - Unidentified- Reversed)
                cj.Attribute5 = je.Account__c;
                cj.Attribute6 = je.Journal_Header__r.Reference_Id__c;
                cj.Attribute7 = (String.isNotBlank(jhRec.Receipt__c) && jhRec.Receipt__r.Is_Reversed__c) ? jhRec.Receipt__r.Reason__c : '';//Receipt Reversal Reason  - Refund/Fund Transfer
                cj.Attribute8 = (String.isNotBlank(jhRec.Receipt__c) && String.isNotBlank(jhRec.Receipt__r.Bank_Detail_Configuration__c)) ? jhRec.Receipt__r.Bank_Detail_Configuration__r.Bank_Detail__c : '';//Receipt bank account (That will be reference for CM reconciliation)
                //cj.Attribute9 = (String.isNotBlank(jhRec.Account__r.Tax_Registration_Number__c)) ? ('|'+jhRec.Account__r.Tax_Registration_Number__c) : '';//Tax Rate Code | Tax Registration Number
                cj.Attribute9 = je.Tax_Rate_Code__c+'|'+jhRec.Account__r.Tax_Registration_Number__c;//Tax Rate Code | Tax Registration Number
                cj.Attribute10 = (String.isNotBlank(jhRec.Receipt__c) && String.isNotBlank(jhRec.Receipt__r.Payment_Method__c)) ? jhRec.Receipt__r.Payment_Method__c : '';//Payment Method - Wire Transfer/Credit card etc…
                cj.reconciliationReference = transref;
                i++;
                requestWrapper.CreateGlJournals.add(cj);
            }
            
            String sInputValue = JSON.serialize(requestWrapper);
            system.debug('Request Body--->'+sInputValue);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:FusionCloud/XXADG_REST_FUSIO_CREAT_GL_JOURN/1.0/');
            request.setMethod('POST');
            request.setTimeout(120000);
            request.setHeader('content-type','application/json');
            request.setBody(sInputValue);
            HTTPResponse objHTTPResponse = http.send(request);
            system.debug('objHTTPResponse--->'+objHTTPResponse);
            system.debug('objHTTPResponse Body--->'+objHTTPResponse.getBody());
            //save Payload on fail for reference purpose
            JEsStatusFromOracle.savePayload('FusionCloud/XXADG_REST_FUSIO_CREAT_GL_JOURN/1.0/',sInputValue,jhId,objHTTPResponse.getBody(),jhRec.Reference_Id__c);
            
            OutputParameters outWrap = (OutputParameters)JSON.deserialize(objHTTPResponse.getBody(), OutputParameters.class);
            system.debug('outWrap--->'+outWrap);
            if(outWrap != null){
                jhRec.Oracle_InstanceId__c = outWrap.InstanceId; jhRec.Oracle_RequestId__c = outWrap.RequestId; jhRec.Oracle_Status__c = outWrap.Status; jhRec.Error_Message__c = outWrap.ErrorMessage;
                update jhRec;
            }
        } catch(Exception ex){
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
        public string reconciliationReference;        
    }
    
    public class OutputParameters{
        public string RequestId;
        public string Status;
        public string InstanceId;
        public string ErrorMessage;
    }
    
}