public class CreditMemoUtil_New {
    
    public static boolean isFromCreditMemoUpdate = false;
    
	@future(callout = true)
    public static void updateCreditMemoAndCreateJVsFuture(List<String> invIDs){
        //pushToOracleCreditMemo(invIDs);
        updateCreditMemoAndCreateJVs(invIDs);
    }
    
    public static void updateCreditMemoAndCreateJVs(List<String> invIDs){
        if(invIDs <> null && invIDs.size() > 0){
        	try{
                List<Invoice__c> listCreditMemo = new List<Invoice__c>();
                list<Invoice_Line_Item__c> listILT = new List<Invoice_Line_Item__c>();
                for(Invoice__c objInv : [SELECT Id,Name,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,Entity__r.Oracle_Party_Id__c,Converted_Invoice_Balance__c,
                                      Oracle_Invoice_Type__c, Oracle_Invoice_Id__c,Oracle_GL_Date__c,Is_Refundable__c,Total_Invoice_Amount__c,GL_Date__c,
                                      Payment_Currency__c, Credit_Memo_Type__c,Source_System__c,Source_Invoice_Id__c,Conversion_Rate__c,
                                      (SELECT Id,Name,Item_Reference__c,Amount__c, Invoice__c, Invoice_Line_Item__r.Invoice__r.Source_Invoice_Id__c,Invoice__r.Oracle_Invoice_Id__c,Line_No__c,
                                       Tax_Amount__c,Item_Description__c,Tax__c,Invoice_Line_Item__r.Tax__c,Department__c,Service_Type__c,Course_Type__c,Schools__c,Quantity__c,Revenue_Type__c,Line_Description__c 
                                       FROM Invoice_Line_Items__r WHERE RECORDTYPE.Name = 'Invoice Line Item') 
                                      FROM Invoice__c WHERE Id IN: invIDs AND From_Data_Migration__c = false]){
                                          
                	//String jsonBody = ConstructInvoicePayload(inv);
                    List<Invoice_Line_Item__c> lstInvoiceLineItems = isFromCreditMemoUpdate ? objInv.Invoice_Line_Items1__r : objInv.Invoice_Line_Items__r;
                    Map<String, Decimal> mapInvoiceWithAmount = new Map<String, Decimal>();
                    map<string, decimal> mapInvAmounts = new map<string, decimal>();
                    if(lstInvoiceLineItems != null && !lstInvoiceLineItems.isEmpty()){
                        Decimal amountVal = 0;Integer lineNo = 1;
                        for(Invoice_Line_Item__c InvLI : lstInvoiceLineItems){
                            if(objInv.Credit_Memo_Type__c == 'Debit'){InvLI.Amount__c = InvLI.Amount__c > 0 ? InvLI.Amount__c : InvLI.Amount__c*-1;
                                InvLI.Tax_Amount__c = InvLI.Tax_Amount__c > 0 ? InvLI.Tax_Amount__c : InvLI.Tax_Amount__c*-1;
                            }else{ InvLI.Amount__c = InvLI.Amount__c > 0 ? InvLI.Amount__c*-1 : InvLI.Amount__c;
                                InvLI.Tax_Amount__c = InvLI.Tax_Amount__c > 0 ? InvLI.Tax_Amount__c*-1 : InvLI.Tax_Amount__c;
                            }   
                            invLi.line_No__c = lineNo; lineNo++;
                            if( mapInvoiceWithAmount.get(InvLI.Invoice_Line_Item__r.Invoice__r.Source_Invoice_Id__c) <> null){ amountVal +=  mapInvoiceWithAmount.get(InvLI.Invoice_Line_Item__r.Invoice__r.Source_Invoice_Id__c); }
                            amountVal += (InvLI.Amount__c);mapInvoiceWithAmount.put(InvLI.Invoice_Line_Item__r.Invoice__r.Source_Invoice_Id__c,amountVal);
                            if(String.isBlank(InvLI.Tax__c) ){InvLI.Tax__c = '0%';}
                            String descr = InvLI.Item_Description__c != null ? InvLI.Item_Description__c : InvLI.Line_Description__c;
                        }
                        objInv.Status__c = 'Invoiced'; objInv.Invoice_Balance__c = amountVal;
                        objInv.Converted_Invoice_Balance__c = objInv.Payment_Currency__c == 'USD' ? amountVal * objInv.Conversion_Rate__c : amountVal;
                        objInv.Journal_Created__c = true; objInv.Oracle_Response_Message__c = 'Journal Vouchers Created';
                        
                        if(objInv <> null ){listCreditMemo.add(objInv);}
                        if(objInv.Invoice_Line_Items__r <> null && objInv.Invoice_Line_Items__r.size() > 0){listILT.addAll(lstInvoiceLineItems);}
                    }
            	}
                if(listCreditMemo <> null && listCreditMemo.size() > 0){ update listCreditMemo;}
                if(listILT <> null && listILT.size() > 0){update listILT;}
                List<Id> creditMemoIds = new List<Id>();
                for(Invoice__c invObj : listCreditMemo){creditMemoIds.add(invObj.Id);}
                BM_JournalEntryEngine.creditMemoCreationJournal(creditMemoIds);
            }catch(Exception ex){ String sMessage = ex.getMessage(); Log__c objLog = new Log__c();
                if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} 
                else {objLog.Message__c = sMessage;}//end if
                objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName();insert objLog;
                //return ex.getMessage();
            }
        }
    }
}