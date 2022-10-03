global class BalanceHistoryBatch implements Database.Batchable<sObject> {

    Date glDate;
    Financial_Report__c finReportObj;
    public BalanceHistoryBatch(Date glDate, Financial_Report__c finReportObj) {
        this.glDate = glDate;
        this.finReportObj = finReportObj;
    }
    
    //start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        String query = 'select id, Operating_Unit__r.Operating_Unit_Name__c FROM Account';// WHERE Id = \'0012500001A8PvCAAV\'';
        if(Test.isRunningTest()){
            query += ' LIMIT 1';    
        }
        
        return Database.getQueryLocator(query);
        
    }

    //execute method
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        system.debug('glDate==>>' + glDate);
        
        List<Invoice_Receipt_Detail__c> invoiceLst = new List<Invoice_Receipt_Detail__c>();
        List<Invoice_Receipt_Detail__c> receiptLst = new List<Invoice_Receipt_Detail__c>();
        List<Invoice_Receipt_Detail__c> creditMemoLst = new List<Invoice_Receipt_Detail__c>();
        List<Invoice_Receipt_Detail__c> invoiceReceiptLst = new List<Invoice_Receipt_Detail__c>();
        Id accountId = scope[0].Id;
        
        invoiceLst = getInvoiceInvoiceReceiptList(accountId, glDate);
        receiptLst = getReceiptInvoiceReceiptList(accountId, glDate);
        creditMemoLst = getCreditMemoInvoiceReceiptList(accountId, glDate);
        system.debug('invoiceLst==>>' + invoiceLst.size());
        system.debug('receiptLst==>>' + receiptLst.size());
        system.debug('creditMemoLst==>>' + creditMemoLst.size());
        invoiceReceiptLst.addAll(invoiceLst);
        invoiceReceiptLst.addAll(receiptLst);
        invoiceReceiptLst.addAll(creditMemoLst);
        //system.debug('invoiceReceiptLst==>>' + invoiceReceiptLst.size());
        if(!invoiceReceiptLst.isEmpty()){
            //system.debug('invoiceReceiptLst==>>' + invoiceReceiptLst.size());
            INSERT invoiceReceiptLst;
        }
    }   
    
    public List<Invoice_Receipt_Detail__c> getCreditMemoInvoiceReceiptList(Id accountId, Date glDate){
        List<Invoice_Receipt_Detail__c> creditMemoLst = new List<Invoice_Receipt_Detail__c>();
        
        for(Invoice__c invObj : [SELECT Id, RecordType.Name, Entity__c, Invoice_Balance__c,Total_Invoice_Amount_OC__c ,
                                 (SELECT Id, Calculated_Amount__c, Amount__c
                                            FROM Invoice_Line_Items__r
                                            WHERE GL_Date__c != null AND GL_Date__c <= :glDate AND Calculated_Amount__c != null),
                                 (SELECT Id, Calculated_Amount__c, Amount__c, Total_Amount__c
                                            FROM Invoice_Line_Items1__r
                                            WHERE GL_Date__c != null AND GL_Date__c <= :glDate AND Amount__c != null)
                                 FROM Invoice__c WHERE GL_Date__c != null AND GL_Date__c <= :glDate AND Entity__c = :accountId AND 
                                     		Status__c != 'Cancelled' AND ((Status__c = 'Success' AND Legacy_Data__c = true) OR Status__c = 'Approved' OR Status__c = 'Invoiced') AND RecordType.Name = 'Credit Memo' AND Oracle_Invoice_Id__c != null]){
            Decimal invoiceBalance = 0;
            Decimal amountApplied = 0;
            if(invObj.Invoice_Line_Items__r != null && invObj.Invoice_Line_Items__r.size() > 0){
                invoiceBalance = getInvoiceBalance(invObj.Invoice_Line_Items__r);    
            }
            system.debug('invoiceBalance==>>' + invObj.Id + '==>>' + invoiceBalance);
            if(invObj.Invoice_Line_Items1__r != null && invObj.Invoice_Line_Items1__r.size() > 0){
                amountApplied = getCreditMemoAmountApplied(invObj.Invoice_Line_Items1__r);
            }
                                     
            system.debug('amountApplied==>>' + invObj.Id + '==>>' + amountApplied);
            Invoice_Receipt_Detail__c invoiceReceipt = new Invoice_Receipt_Detail__c();
            invoiceReceipt.Entity__c = invObj.Entity__c;
            invoiceReceipt.Financial_Report__c = finReportObj.Id;
            invoiceReceipt.Invoice__c = invObj.Id;
            invoiceReceipt.Type__c = invObj.RecordType.Name;
            invoiceReceipt.Amount__c = invoiceBalance;
            invoiceReceipt.Balance__c = invoiceBalance + amountApplied;
            if(invObj.RecordType.Name == 'Credit Memo'){
                invoiceReceipt.Balance__c = invObj.Invoice_Balance__c;
            }
            creditMemoLst.add(invoiceReceipt);
        }
        
        return creditMemoLst;
    }
    
    public List<Invoice_Receipt_Detail__c> getReceiptInvoiceReceiptList(Id accountId, Date glDate){

        List<Invoice_Receipt_Detail__c> receiptLst = new List<Invoice_Receipt_Detail__c>();
        for(Receipt__c recptObj : [SELECT Id, Receipt_Type__c, Receipt_Balance__c,Entity__c,Amount_in_AED__c,Amount__c, From_Data_Migration__c, Refund_Amount__c, Transferred_Amount__c, Remaning_Amount__c
                                        /*(SELECT Id, Amount_Applied__c, Oracle_Applied_Amount__c FROM Related_Invoices__r
                                         WHERE ((Applied_Date__c != null AND Applied_Date__c <= :glDate AND Amount_Applied__c != null) OR (Oracle_Applied_Amount__c != null AND Oracle_Applied_Amount__c > 0)) AND Status__c != 'Receipt Reversed' AND CreatedDate <= :glDate) */
                                    FROM Receipt__c
                                    WHERE Entity__c = :accountId AND GL_Date__c != null AND (GL_Date__c <= :glDate OR (GL_Date__c > :glDate AND Oracle_Receipt_Id__c != null)) AND (Status__c = 'Success' OR Status__c = 'Approved')
                                  	AND Oracle_Receipt_Id__c != null]){
            
            /*system.debug('recptObj==>>' + recptObj.Id);
            Decimal receiptBalance = recptObj.Amount__c != null ? recptObj.Amount__c : 0.00;
            Decimal receiptAmountApplied = 0;
            if(recptObj.Related_Invoices__r != null && recptObj.Related_Invoices__r.size() > 0){
                receiptAmountApplied = getAmountApplied(recptObj.Related_Invoices__r, recptObj.From_Data_Migration__c);
            }
                                        if(recptObj.Refund_Amount__c != null && recptObj.Refund_Amount__c > 0){
                                            receiptAmountApplied += recptObj.Refund_Amount__c;
                                        } 
                                        if(recptObj.Transferred_Amount__c != null && recptObj.Transferred_Amount__c > 0){
                                            receiptAmountApplied += recptObj.Transferred_Amount__c;
                                        }  */
                                        
            Invoice_Receipt_Detail__c invoiceReceipt = new Invoice_Receipt_Detail__c();
            invoiceReceipt.Entity__c = recptObj.Entity__c;
            invoiceReceipt.Financial_Report__c = finReportObj.Id;
            invoiceReceipt.Receipt__c = recptObj.Id;
            invoiceReceipt.Type__c = 'Receipt';
            invoiceReceipt.Amount__c = recptObj.Amount__c;
            invoiceReceipt.Balance__c = recptObj.Receipt_Balance__c;//receiptBalance - receiptAmountApplied;
            receiptLst.add(invoiceReceipt);
        }
        return receiptLst;
    }
    
    public List<Invoice_Receipt_Detail__c> getInvoiceInvoiceReceiptList(Id accountId, Date glDate){
        List<Invoice_Receipt_Detail__c> invoiceLst = new List<Invoice_Receipt_Detail__c>();
        for(Invoice__c invoiceObj : [SELECT Id, RecordType.Name, Entity__c, Invoice_Balance__c, Total_Invoice_Amount_OC__c, From_Data_Migration__c /*,
                                        (SELECT Id, Amount_Applied__c, Oracle_Applied_Amount__c 
                                            FROM Related_Receipts__r 
                                            WHERE Status__c != 'Receipt Reversed' AND ((Applied_Date__c != null AND Applied_Date__c <= :glDate AND Amount_Applied__c != null) OR (Oracle_Applied_Amount__c != null AND Oracle_Applied_Amount__c > 0)) AND LastModifiedDate <= :glDate),
                                        (SELECT Id, Calculated_Amount__c, Amount__c, Activity_Name__c, RecordType.Name, Total_Amount_without_Discount__c, Is_Credit_Memo_Application__c
                                            FROM Invoice_Line_Items__r
                                            WHERE Status__c != 'Cancelled' AND GL_Date__c != null AND GL_Date__c <= :glDate AND Total_Amount_without_Discount__c != null AND (RecordType.Name = 'Invoice Line Item' OR RecordType.Name = 'Adjustment')) */    
                                       FROM Invoice__c 
                                       WHERE GL_Date__c != null AND GL_Date__c <= :glDate AND Entity__c = :accountId AND 
                                     		Status__c != 'Cancelled' AND  ((Status__c = 'Success' AND Legacy_Data__c = true) OR Status__c = 'Approved' OR Status__c = 'Invoiced' OR Status__c = 'Consumed') AND (RecordType.Name = 'Invoice' OR (RecordType.Name = null AND Service_Request__c != '')) AND Oracle_Invoice_Id__c != null]){
            /*Decimal invoiceBalance = 0; 
            Decimal adjustmentBalance = 0;
			Decimal CMApplicationBalance = 0;
            Decimal amountApplied = 0;
            if(invoiceObj.Invoice_Line_Items__r != null && invoiceObj.Invoice_Line_Items__r.size() > 0){
                invoiceBalance = getInvoiceBalanceIncludingAdjustmentBalance(invoiceObj.Invoice_Line_Items__r);
                adjustmentBalance = getInvoiceAdjustmentBalance(invoiceObj.Invoice_Line_Items__r);
                CMApplicationBalance = getInvoiceCMApplicationBalance(invoiceObj.Invoice_Line_Items__r);
            }
            system.debug('invoiceBalance==>>' + invoiceObj.Id + '==>>' + invoiceBalance);
            if(invoiceObj.Related_Receipts__r != null && invoiceObj.Related_Receipts__r.size() > 0){
                amountApplied = getInvoiceAmountApplied(invoiceObj.Related_Receipts__r, invoiceObj.From_Data_Migration__c);
            }
            system.debug('amountApplied==>>' + invoiceObj.Id + '==>>' + amountApplied);*/
            Invoice_Receipt_Detail__c invoiceReceipt = new Invoice_Receipt_Detail__c();
            invoiceReceipt.Entity__c = invoiceObj.Entity__c;
            invoiceReceipt.Financial_Report__c = finReportObj.Id;
            invoiceReceipt.Invoice__c = invoiceObj.Id;
            invoiceReceipt.Type__c = invoiceObj.RecordType.Name;
            invoiceReceipt.Amount__c = invoiceObj.Total_Invoice_Amount_OC__c; //invoiceBalance;
            invoiceReceipt.Balance__c = invoiceObj.Invoice_Balance__c; //invoiceBalance - (amountApplied + adjustmentBalance + CMApplicationBalance);
            invoiceLst.add(invoiceReceipt);
        }
        
        return invoiceLst;
    }
    
    /*public Decimal getInvoiceCMApplicationBalance(List<Invoice_Line_Item__c> invoiceLineItemLst){
        Decimal creditMemoApplAmnt = 0;
        
        for(Invoice_Line_Item__c lineItemObj : invoiceLineItemLst){
        	if(lineItemObj.RecordType.Name == 'Invoice Line Item' && lineItemObj.Total_Amount_without_Discount__c != null && lineItemObj.Is_Credit_Memo_Application__c){
                creditMemoApplAmnt += lineItemObj.Total_Amount_without_Discount__c;
            }
        }
        return creditMemoApplAmnt;
    }
    
    public Decimal getInvoiceAdjustmentBalance(List<Invoice_Line_Item__c> invoiceLineItemLst){
        Decimal adjBalance = 0;
        Decimal negativeLineItemBalance = 0;
        for(Invoice_Line_Item__c lineItemObj : invoiceLineItemLst){
            if((lineItemObj.RecordType.Name == 'Adjustment' && (lineItemObj.Activity_Name__c.contains('Bank Ch') || lineItemObj.Activity_Name__c.contains('Rounding')))){
                Decimal adjAmt = lineItemObj.Amount__c < 0 ? lineItemObj.Amount__c * -1 : lineItemObj.Amount__c;
                adjBalance += adjAmt;
            }else if(lineItemObj.RecordType.Name == 'Invoice Line Item' && lineItemObj.Total_Amount_without_Discount__c < 0){
                negativeLineItemBalance += lineItemObj.Total_Amount_without_Discount__c * -1;
            }
        }
        return (adjBalance + negativeLineItemBalance);
    }
    
    public Decimal getInvoiceBalanceIncludingAdjustmentBalance(List<Invoice_Line_Item__c> invoiceLineItemLst){
        Decimal amountSum = 0;
        Decimal adjAmount = 0;
        Decimal creditMemoApplAmnt = 0;
        for(Invoice_Line_Item__c lineItemObj : invoiceLineItemLst){
            
            if(lineItemObj.RecordType.Name == 'Invoice Line Item' && lineItemObj.Total_Amount_without_Discount__c != null && !lineItemObj.Is_Credit_Memo_Application__c && lineItemObj.Total_Amount_without_Discount__c > 0){
                amountSum += lineItemObj.Total_Amount_without_Discount__c; //!= 0 ? lineItemObj.Total_Amount_without_Discount__c : (lineItemObj.Amount__c > 0 ? lineItemObj.Amount__c : 0);
            }/*else if(lineItemObj.RecordType.Name == 'Invoice Line Item' && lineItemObj.Total_Amount_without_Discount__c != null && lineItemObj.Is_Credit_Memo_Application__c){
                creditMemoApplAmnt += lineItemObj.Total_Amount_without_Discount__c;
            }
            if(lineItemObj.RecordType.Name == 'Adjustment' && (lineItemObj.Activity_Name__c.contains('Bank Ch') || lineItemObj.Activity_Name__c.contains('Rounding'))){
                Decimal adjAmt = lineItemObj.Amount__c < 0 ? lineItemObj.Amount__c * -1 : lineItemObj.Amount__c;
                adjAmount += adjAmt;
            }
        }
        Decimal invAmount = (amountSum ) ;
        return invAmount;
    }*/
    
    public Decimal getInvoiceBalance(List<Invoice_Line_Item__c> invoiceLineItemLst){
        Decimal amountSum = 0;
        for(Invoice_Line_Item__c lineItemObj : invoiceLineItemLst){
            
            if(lineItemObj.Calculated_Amount__c != null){
                amountSum += lineItemObj.Calculated_Amount__c != 0 ? lineItemObj.Calculated_Amount__c : (lineItemObj.Amount__c > 0 ? lineItemObj.Amount__c : 0);
            }
        }
        return amountSum;
    }
    
    /*public Decimal getInvoiceAmountApplied(List<Related_Invoice_Receipt__c> relatedInvoiceReceiptLst, Boolean fromDataMigration){
        Decimal amountApplied = 0;
        for(Related_Invoice_Receipt__c relatedInvRecObj : relatedInvoiceReceiptLst){
            if(fromDataMigration && relatedInvRecObj.Amount_Applied__c != null){
                amountApplied += relatedInvRecObj.Amount_Applied__c; 
            }else if(relatedInvRecObj.Oracle_Applied_Amount__c != null){
                amountApplied += relatedInvRecObj.Oracle_Applied_Amount__c;    
            }
        }
        return amountApplied;
    }
    
    public Decimal getAmountApplied(List<Related_Invoice_Receipt__c> relatedInvoiceReceiptLst, Boolean fromDataMigration){
        Decimal amountApplied = 0;
        for(Related_Invoice_Receipt__c relatedInvRecObj : relatedInvoiceReceiptLst){
            if(fromDataMigration && relatedInvRecObj.Oracle_Applied_Amount__c != null){
                amountApplied += relatedInvRecObj.Oracle_Applied_Amount__c; 
            }else if(relatedInvRecObj.Amount_Applied__c != null){
                amountApplied += relatedInvRecObj.Amount_Applied__c;    
            }
        }
        return amountApplied;
    }*/
    
    public Decimal getCreditMemoAmountApplied(List<Invoice_Line_Item__c> invLineItemLst){
        Decimal amountApplied = 0;
        for(Invoice_Line_Item__c lineItemObj : invLineItemLst){
            if(lineItemObj.Total_Amount__c != null){
                amountApplied += lineItemObj.Total_Amount__c;    
            }
        }
        return amountApplied;
    }

    global void finish(Database.BatchableContext BC) {
        User urObj = [SELECT Id, Name, Email FROM User WHERE Id = :UserInfo.getUserId()];
        
        String msgBody = '<p>Dear '+urObj.name+',</p> <p>The Financial Dashboard is prepared according to the GL Date you selected, please go on dashboard and click refresh to see the updated data.</p>';
        msgBody += 'Thanks ';
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {urObj.Email};
        System.debug('toAdresses------------------->'+toAddresses);
        mail.setToAddresses(toAddresses);
        mail.setSubject('Dashboard Updated');
        mail.setHtmlBody(msgBody);
        List<CRM_Send_Email_Configuration__mdt> listSendEmailConfiguration =  [SELECT id, MasterLabel, CRM_Email__c FROM CRM_Send_Email_Configuration__mdt where CRM_Default__c = true limit 1];
        String orgWideId = null;
        if(listSendEmailConfiguration <> null && listSendEmailConfiguration.size() > 0) {
            orgWideId = [SELECT ID FROM OrgWideEmailAddress WHERE Address =:listSendEmailConfiguration[0].CRM_Email__c].Id;
        }
        if(orgWideId <> null && orgWideId <> '') {
            mail.setOrgWideEmailAddressId(orgWideId);
        }
        system.debug('mail==>>');
        Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] {mail});
        system.debug('er==>>' + er);
    }
}