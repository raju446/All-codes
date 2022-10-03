public class InvoiceUtil_New {
    
    public static Boolean checkRevenueType(Invoice__c invObj){
        for(Invoice_Line_Item__c invLineObj : invObj.Invoice_Line_Items__r){
            if(String.isBlank(invLineObj.Revenue_Type__c)){
                return false;
            }
        }
        return true;
    }
    
    /*public static void updateInvoiceAndCreateJournalEntries(List<String> invIDs){
        if(invIDs <> null && invIDs.size() > 0){
            try{
                
                List<Invoice__c> listInvoice = new List<Invoice__c>();
                List<Invoice_Line_Item__c> invoiceLineLst = new List<Invoice_Line_Item__c>();
                List<Id> invoiceIds = new List<Id>();
                for(Invoice__c inv : [SELECT Id,Name,Source_System__c,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,GL_Date__c,Oracle_GL_Date__c,Entity__r.Oracle_Party_Id__c,Invoice_Class__c,Oracle_Invoice_Type__c,Source_Invoice_Id__c,Transaction_Type__c,Conversion_Rate__c,
                                      Payment_Term__c,Payment_Currency__c,Status__c,Total_Invoice_Amount__c,Invoice_Amount__c,Tax_Amount__c,Discount_Amount__c,Discount_Tax_Amount__c,Converted_Discount_Amount__c,Converted_Discount_Tax_Amount__c,Converted_Invoice_Amount__c,Converted_Tax_Amount__c,Converted_Invoice_Balance__c,
                                      (SELECT Id,Name,Taxable_Discount_Amount__c,Discount_Amount__c,Item_Reference__c,Amount__c,Total_Amount__c,Is_Discount__c,
                                      Tax_Amount__c,Item_Description__c,Line_Description__c,Tax__c,Department__c,Service_Type__c,Course_Type__c,Schools__c,Quantity__c,Revenue_Type__c FROM Invoice_Line_Items__r WHERE RECORDTYPE.Name = 'Invoice Line Item' AND Status__c != 'Cancelled') FROM Invoice__c WHERE Id IN: invIDs and Service_Request__c = null LIMIT 1]){
                        Boolean revenueTypeExists = checkRevenueType(inv);
                        if(!revenueTypeExists){
                            inv.Oracle_Response_Message__c = 'Revenue Mapping is missing on line item';
                            listInvoice.add(inv);
                            continue;
                        }
                        inv.Status__c = 'Invoiced';
                        inv.Journal_Created__c = true;
                        
                        Decimal invoiceAmnt = 0;
                        Decimal invoiceTaxAmnt = 0;
                        Decimal convertedInvoiceAmnt = 0;
                        Decimal convertedInvoiceTaxAmnt = 0;
                        Decimal discountAmnt = 0;
                        Decimal discountTaxAmnt = 0;
                        Decimal convertedDiscountAmnt = 0;
                        Decimal convertedDiscountTaxAmnt = 0;
                        Integer i = 1;
                        for(Invoice_Line_Item__c lineItemObj : inv.Invoice_Line_Items__r){
                            if(!lineItemObj.is_Discount__c){
                                invoiceAmnt += lineItemObj.Amount__c;
                                convertedInvoiceAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;
                                invoiceTaxAmnt += lineItemObj.Tax_Amount__c;
                                convertedInvoiceTaxAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;    
                            }else{
                                discountAmnt += lineItemObj.Amount__c;
                                convertedDiscountAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;
                                discountTaxAmnt += lineItemObj.Tax_Amount__c;
                                convertedDiscountTaxAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;
                            }
                            lineItemObj.Line_No__c = i;
                            lineItemObj.Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;
                            lineItemObj.Tax_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;
                            lineItemObj.Item_Reference__c = lineItemObj.Name;
                            if(lineItemObj.is_Discount__c){
                                lineItemObj.Discount_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;
                                lineItemObj.Taxable_Discount_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;    
                            }else{
                                lineItemObj.Discount_Amount_Converted__c = 0;
                                lineItemObj.Taxable_Discount_Amount_Converted__c = 0;
                            }
                            
                            i++;
                        }
                        invoiceLineLst.addAll(inv.Invoice_Line_Items__r);
                        inv.Invoice_Balance__c = invoiceAmnt + invoiceTaxAmnt + discountAmnt + discountTaxAmnt; //respObj.P_OP_AMT_INV_BAL != null && respObj.P_OP_AMT_INV_BAL != '' ? Decimal.valueof(respObj.P_OP_AMT_INV_BAL) : inv.Total_Invoice_Amount__c;
                        inv.Converted_Invoice_Balance__c = convertedInvoiceAmnt + convertedInvoiceTaxAmnt + convertedDiscountAmnt + convertedDiscountTaxAmnt; //respObj.P_OP_CONV_AMT_INV_BAL != null && respObj.P_OP_CONV_AMT_INV_BAL != '' ? Decimal.valueof(respObj.P_OP_CONV_AMT_INV_BAL) : 0;
                        
                        inv.Converted_Invoice_Amount__c = convertedInvoiceAmnt; //respObj.P_OP_CONVERTED_AMT != null && respObj.P_OP_CONVERTED_AMT != '' ? Decimal.valueof(respObj.P_OP_CONVERTED_AMT) : 0;
                        inv.Converted_Discount_Amount__c = convertedDiscountAmnt; //respObj.P_OP_CONVERTED_DISCOUNT != null && respObj.P_OP_CONVERTED_DISCOUNT != '' ? Decimal.valueof(respObj.P_OP_CONVERTED_DISCOUNT) : 0;
                        inv.Converted_Discount_Tax_Amount__c = convertedDiscountTaxAmnt; //respObj.P_OP_CONV_DISCOUNT_TAX_AMOUNT != null && respObj.P_OP_CONV_DISCOUNT_TAX_AMOUNT != '' ? Decimal.valueof(respObj.P_OP_CONV_DISCOUNT_TAX_AMOUNT) : 0;
                        inv.Converted_Tax_Amount__c = convertedInvoiceTaxAmnt; //respObj.P_OP_CONVERTED_TAXAMT != null && respObj.P_OP_CONVERTED_TAXAMT != '' ? Decimal.valueof(respObj.P_OP_CONVERTED_TAXAMT) : 0;
                        
                        inv.Invoice_Amount__c = invoiceAmnt; //respObj.P_OP_INV_AMOUNT != null && respObj.P_OP_INV_AMOUNT != '' ? Decimal.valueof(respObj.P_OP_INV_AMOUNT) : 0;
                        inv.Discount_Amount__c = discountAmnt; //respObj.P_OP_DISCOUNT_AMOUNT != null && respObj.P_OP_DISCOUNT_AMOUNT != '' ? Decimal.valueof(respObj.P_OP_DISCOUNT_AMOUNT) : 0;
                        inv.Discount_Tax_Amount__c = discountTaxAmnt; //respObj.P_OP_DISCOUNT_TAX_AMOUNT != null && respObj.P_OP_DISCOUNT_TAX_AMOUNT != '' ? Decimal.valueof(respObj.P_OP_DISCOUNT_TAX_AMOUNT) : 0;
                        inv.Tax_Amount__c = invoiceTaxAmnt; //respObj.P_OP_TAX_AMOUNT != null && respObj.P_OP_TAX_AMOUNT != '' ? Decimal.valueof(respObj.P_OP_TAX_AMOUNT) : 0;
                        
                        
                        listInvoice.add(inv);
                        invoiceIds.add(inv.Id);
                }
                system.debug('listInvoice==>>' + listInvoice);
                if(listInvoice <> null && listInvoice.size() > 0){
                    update listInvoice;
                    BM_JournalEntryEngine.invoiceCreationJournal(invoiceIds);
                }
                
                if(invoiceLineLst <> null && invoiceLineLst.size() > 0){
                   update invoiceLineLst;
                }

            } catch(Exception ex){
                system.debug(ex.getLineNumber());
                String sMessage = ex.getMessage();
                Log__c objLog = new Log__c();
                if(sMessage .length() > 240) {
                    objLog.Message__c = sMessage.subString(0,240);
                } else {
                    objLog.Message__c = sMessage;
                }
                
                objLog.Line_Number__c = ex.getLineNumber();
                objLog.Stack_Trace__c =  ex.getStackTraceString();
                objLog.Type_Name__c = ex.getTypeName();
                insert objLog;
            }
        }   
    }*/
    @Future
    public static void updateInvoiceAndCreateJournalEntries_Future(List<String> invIDs){
        InvoiceUtil_New.updateInvoiceAndCreateJournalEntries(invIds);
    }
    
    public static string updateInvoiceAndCreateJournalEntries(List<String> invIDs){
        List<Invoice__c> listInvoice = new List<Invoice__c>();
        if(invIDs <> null && invIDs.size() > 0){
            try{
                for(Invoice__c inv : [SELECT Id,Name,Source_System__c,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,GL_Date__c,Oracle_GL_Date__c,Entity__r.Oracle_Party_Id__c,Invoice_Class__c,Oracle_Invoice_Type__c,Source_Invoice_Id__c,Transaction_Type__c,Conversion_Rate__c,
                                      Payment_Term__c,Payment_Currency__c,Status__c,Total_Invoice_Amount__c,Invoice_Amount__c,Tax_Amount__c,Discount_Amount__c,Discount_Tax_Amount__c,Converted_Discount_Amount__c,Converted_Discount_Tax_Amount__c,Converted_Invoice_Amount__c,Converted_Tax_Amount__c,Converted_Invoice_Balance__c,
                                      (SELECT Id,Name,Taxable_Discount_Amount__c,Discount_Amount__c,Item_Reference__c,Amount__c,Total_Amount__c,Revenue_Type__c,Service_Type__c,Schools__c,Course_Type__c,Department__c,Is_Discount__c,
                                      Tax_Amount__c,Item_Description__c,Line_Description__c,Tax__c FROM Invoice_Line_Items__r WHERE RECORDTYPE.Name = 'Invoice Line Item' AND Status__c != 'Cancelled') FROM Invoice__c WHERE Id =: invIds[0] and Service_Request__c = null AND Journal_Created__c = FALSE LIMIT 1]){
                        
                        if(inv.Invoice_Line_Items__r.isEmpty()){ 
                            inv.Oracle_Response_Message__c = 'InvoiceLineItem is not available on invoice.'; 
                            update inv; 
                            return null; 
                        }
                        Boolean revenueTypeExists = checkRevenueType(inv);
                        if(!revenueTypeExists){
                            inv.Oracle_Response_Message__c = 'Revenue Mapping is missing on line item';update inv;return null;
                        }
                        inv.Status__c = 'Invoiced';
                                          inv.Journal_Created__c = true;
                                          inv.Oracle_Response_Message__c = 'Journal Vouchers Created';
                        
                        Decimal invoiceAmnt = 0;Decimal invoiceTaxAmnt = 0;Decimal convertedInvoiceAmnt = 0;Decimal convertedInvoiceTaxAmnt = 0;Decimal discountAmnt = 0;Decimal discountTaxAmnt = 0;Decimal convertedDiscountAmnt = 0;Decimal convertedDiscountTaxAmnt = 0;
                        Integer j = 1;
                        for(Invoice_Line_Item__c lineItemObj : inv.Invoice_Line_Items__r){
                            if(!lineItemObj.is_Discount__c){
                                invoiceAmnt += lineItemObj.Amount__c;
                                convertedInvoiceAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;
                                invoiceTaxAmnt += lineItemObj.Tax_Amount__c;
                                convertedInvoiceTaxAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;    
                            }else{
                                discountAmnt += lineItemObj.Amount__c;
                                convertedDiscountAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;
                                discountTaxAmnt += lineItemObj.Tax_Amount__c;
                                convertedDiscountTaxAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;
                            }
                            lineItemObj.Line_No__c = j;
                            lineItemObj.Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;
                            lineItemObj.Tax_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;
                            lineItemObj.Item_Reference__c = lineItemObj.Name;
                            if(lineItemObj.is_Discount__c){
                                lineItemObj.Discount_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;
                                lineItemObj.Taxable_Discount_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;    
                            }else{
                                lineItemObj.Discount_Amount_Converted__c = 0;
                                lineItemObj.Taxable_Discount_Amount_Converted__c = 0;
                            }
                            
                            j++;
                        }
                        
                        inv.Invoice_Balance__c = invoiceAmnt + invoiceTaxAmnt + discountAmnt + discountTaxAmnt;
                        inv.Converted_Invoice_Balance__c = convertedInvoiceAmnt + convertedInvoiceTaxAmnt + convertedDiscountAmnt + convertedDiscountTaxAmnt;
                        
                        inv.Converted_Invoice_Amount__c = convertedInvoiceAmnt; inv.Converted_Discount_Amount__c = convertedDiscountAmnt;inv.Converted_Discount_Tax_Amount__c = convertedDiscountTaxAmnt; inv.Converted_Tax_Amount__c = convertedInvoiceTaxAmnt;
                        
                        inv.Invoice_Amount__c = invoiceAmnt;inv.Discount_Amount__c = discountAmnt; inv.Discount_Tax_Amount__c = discountTaxAmnt; inv.Tax_Amount__c = invoiceTaxAmnt;
                                          
                        List<Related_Invoice_Receipt__c> applicationLst = new List<Related_Invoice_Receipt__c>();
                        List<String> applicationIds = new List<String>();
                        /*applicationLst = [SELECT Id, Invoice__c, Invoice__r.Payment_Currency__c, Invoice__r.Invoice_Balance__c, Receipt__c, Receipt__r.Amount__c, Receipt__r.Remaning_Amount__c FROM Related_Invoice_Receipt__c WHERE Invoice__c = :invIds[0] AND Journal_Created__c = False AND Receipt__r.Journal_Created__c = true LIMIT 1];
                        if(!applicationLst.isEmpty()){
                            for(Related_Invoice_Receipt__c appObj : applicationLst){
                                appObj.Journal_Created__c = true;
                                if(appObj.Invoice__r.Invoice_Balance__c <= appObj.Receipt__r.Remaning_Amount__c){
                                    appObj.Amount_Applied__c = appObj.Invoice__r.Invoice_Balance__c;
                                    appObj.Oracle_Converted_Applied_Amount__c = appObj.Invoice__r.Payment_Currency__c == 'USD' ? appObj.Invoice__r.Invoice_Balance__c * appObj.Invoice__r.Conversion_Rate__c : appObj.Invoice__r.Invoice_Balance__c;
                                    inv.Invoice_Balance__c = 0;
                                    inv.Converted_Invoice_Balance__c = 0;
                                }else if(appObj.Invoice__r.Invoice_Balance__c > appObj.Receipt__r.Remaning_Amount__c){
                                    Decimal remainingInvoiceBalance = appObj.Invoice__r.Invoice_Balance__c - appObj.Receipt__r.Remaning_Amount__c;
                                    appObj.Amount_Applied__c = appObj.Receipt__r.Remaning_Amount__c;
                                    appObj.Oracle_Converted_Applied_Amount__c = appObj.Invoice__r.Payment_Currency__c == 'USD' ? appObj.Receipt__r.Remaning_Amount__c * appObj.Invoice__r.Conversion_Rate__c : appObj.Receipt__r.Remaning_Amount__c;
                                    inv.Invoice_Balance__c = remainingInvoiceBalance;
                                    inv.Converted_Invoice_Balance__c = appObj.Invoice__r.Payment_Currency__c == 'USD' ? remainingInvoiceBalance * appObj.Invoice__r.Conversion_Rate__c : remainingInvoiceBalance;
                                }
                                applicationIds.add(appObj.Id);
                            }
                        }*/
                        
                        update inv; update inv.Invoice_Line_Items__r;
                        //UPDATE applicationLst;
                        BM_JournalEntryEngine.invoiceCreationJournal(new List<Id>{inv.Id});
                        //BM_JournalEntryEngine.receiptApplicationJournalLines(applicationIds);
                }
            } catch(Exception ex){
                String sMessage = ex.getMessage();Log__c objLog = new Log__c();
                if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} else {objLog.Message__c = sMessage;}//end if
                objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName();
                insert objLog;
                return ex.getMessage();
            }return null;
        }return 'Journal Entries Created';
    }
    
    public static void updateCloseDateErrorJVs(Set<Invoice__c> invIDs){
        /*List<Journal_Header__c> jvsToUpdate = new List<Journal_Header__c>();
        Map<Invoice__c,list<Journal_Header__c>> jvMap = new Map<Invoice__c,list<Journal_Header__c>>();
        for(Invoice__c inv : invIDs){
            List<Journal_Header__c> jvLst = [Select Id, GL_Date__c,Oracle_Status__c,Error_Message__c from Journal_Header__c where Invoice__c=:inv.Id AND Oracle_Status__c = 'Error' 
                                         AND Error_Message__c LIKE 'GL Period is not open%'];
            System.debug('jvLst with close GL Date error: '+jvLst);
            System.debug('inv: '+inv);
            jvMap.put(inv,jvLst);
        }
        for(Invoice__c inv : jvMap.keyset()){
            for(Journal_Header__c jh : jvMap.get(inv)){jh.GL_Date__c = inv.GL_Date__c.Date();jh.Oracle_Status__c = 'Draft';jh.Error_Message__c = '';jvsToUpdate.add(jh);
            }
        }
        if(jvsToUpdate.size()>0){update jvsToUpdate;}*/
        
    }
    
    
}