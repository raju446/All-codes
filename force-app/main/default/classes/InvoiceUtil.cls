/**
 * @File Name          : InvoiceUtil.cls
 * @Description        : Invoice Utility Class to push the Invoices to Oracle
 * @Author             : Jayanta Karmakar 
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 10-31-2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    1/27/2020   Jayanta Karmakar     Initial Version
 * 2.0    8/2/2021    Prachi Sinha         Once the Adjustment Invoice line item status changes to 'Invoiced', 
                                           it will be pushed to the corresponding source system
**/

// For Service Request and SR Line Items //Invoice_Amount__c, 
public class InvoiceUtil {
    @future (callout = true)
    public static void pushToOracleFuture(String srid){
        InvoiceUtil.createLineItemAddApplicationJournalEntries(new List<String>{srid});
    }
    public static List<Invoice_Line_Item__c> listInvoiceLineItem = new List<Invoice_Line_Item__c>();
    public static Map<Id,HexaBPM__SR_Price_Item__c> pricingItemMap;
    
    public static string createLineItemAddApplicationJournalEntries(List<String> srIDs){
        Savepoint sp;
        if(srIDs <> null && srIDs.size() > 0){
            try{
                sp = Database.setSavepoint();
                pricingItemMap = new Map<Id,HexaBPM__SR_Price_Item__c>();
                map<string, ID> mapTaxbleSRPwithILT = new map<string, ID>();
                map<string, ID> mapNonTaxbleSRPwithILT = new map<string, ID>();
                Id invoiceId;
                List<Invoice__c> listInvoice = new List<Invoice__c>();
                listInvoice = [SELECT Id,Name,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,GL_Date__c,Entity__r.Oracle_Party_Id__c,Invoice_Class__c,Oracle_Invoice_Type__c,Oracle_GL_Date__c, Converted_Invoice_Balance__c,Entity__c,
                                      Payment_Term__c,Payment_Currency__c,Status__c,Invoice_Amount__c,Tax_Amount__c,Discount_Amount__c,Discount_Tax_Amount__c,Converted_Discount_Amount__c,Converted_Discount_Tax_Amount__c,Converted_Invoice_Amount__c,Converted_Tax_Amount__c,
                               (SELECT Id,Name,Taxable_Discount_Amount__c,Discount_Amount__c,Item_Reference__c,Amount__c,Total_Amount__c,Revenue_Type__c,
                                Service_Type__c,Schools__c,Department__c,Is_Discount__c,SR_Price_Item__c,Tax_Amount__c,Item_Description__c,Line_Description__c,Tax__c, Is_Taxable__c
                                FROM Invoice_Line_Items__r WHERE RECORDTYPE.Name = 'Invoice Line Item') FROM Invoice__c WHERE Service_Request__c IN: srIDs LIMIT 1];
                
                
                if(listInvoice <> null && listInvoice.size() > 0) {
                    invoiceId = listInvoice[0].id;
                    for(Invoice_Line_Item__c eachLine : listInvoice[0].Invoice_Line_Items__r){if(eachLine.Is_Taxable__c){mapTaxbleSRPwithILT.put(eachLine.SR_Price_Item__c, eachLine.id);}else{mapNonTaxbleSRPwithILT.put(eachLine.SR_Price_Item__c, eachLine.id);}}
                }
                
                for(HexaBPM__Service_Request__c ObjSR:[Select Id,Name,HexaBPM__Customer__r.Oracle_Site_Id__c,HexaBPM__SR_Template__c,HexaBPM__SR_Template__r.Invoice_Transaction_Type__c,HexaBPM__Customer__c,HexaBPM__Customer__r.Oracle_Party_Id__c,RecordType.Name, Oracle_Credit_Number__c, Oracle_Invoice_Number__c, Service_Request_Name__c,
                    (Select Id,Name,HexaBPM__Status__c,HexaBPM__Price__c,Tax_Amount__c,Invoice_Type1__c,HexaBPM__Pricing_Line__c,HexaBPM__Product__c,HexaBPM__Product__r.Name,HexaBPM__Pricing_Line__r.Name,Is_Refund_Line__c,Oracle_Response__c,Cost__c,Markup_Amount__c,Cancellation_Fee__c 
                    ,Department__c,Item_Type1__c,Revenue_Type__c,Service_Type__c,Service_Class__c
                    from HexaBPM__SR_Price_Items1__r where HexaBPM__Status__c!='Invoiced' and HexaBPM__Status__c!='Cancelled') 
                    from HexaBPM__Service_Request__c where Id IN: srIDs and HexaBPM__Customer__r.Is_ADGM_Company__c = false LIMIT 1]){
                		
                        for(HexaBPM__SR_Price_Item__c eachItem : objSR.HexaBPM__SR_Price_Items1__r){
                            pricingItemMap.put(eachItem.id, eachItem);
                        }
               			insertInvoiceLineItem(ObjSR, invoiceId, mapTaxbleSRPwithILT, mapNonTaxbleSRPwithILT);
                        
                        
                        listInvoice = [SELECT Id,Name,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,GL_Date__c,Entity__r.Oracle_Party_Id__c,Invoice_Class__c,Oracle_Invoice_Type__c,Oracle_GL_Date__c, Converted_Invoice_Balance__c,Entity__c,
                                      Payment_Term__c,Payment_Currency__c,Status__c,Invoice_Amount__c,Tax_Amount__c,Discount_Amount__c,Discount_Tax_Amount__c,Converted_Discount_Amount__c,Converted_Discount_Tax_Amount__c,Converted_Invoice_Amount__c,Converted_Tax_Amount__c,
                               (SELECT Id,Name,Taxable_Discount_Amount__c,Discount_Amount__c,Item_Reference__c,Amount__c,Total_Amount__c,Revenue_Type__c,
                                Service_Type__c,Schools__c,Department__c,Is_Discount__c,SR_Price_Item__c,Tax_Amount__c,Item_Description__c,Line_Description__c,Tax__c, Is_Taxable__c
                                FROM Invoice_Line_Items__r WHERE RECORDTYPE.Name = 'Invoice Line Item') FROM Invoice__c WHERE Service_Request__c IN: srIDs LIMIT 1];
                        
                        for(HexaBPM__SR_Price_Item__c SRP: ObjSR.HexaBPM__SR_Price_Items1__r){
                            SRP.HexaBPM__Status__c = 'Invoiced';
                        }
                        
                        if(objSR.Service_Request_Name__c=='Sales and Promotion Permit'){
                            List<HexaBPM__Step__c> lstStep = [SELECT id, HexaBPM__SR_Step__c,HexaBPM__Status__c FROM HexaBPM__Step__c WHERE HexaBPM__SR__c=:objSR.Id AND HexaBPM__Summary__c='Generate Permit & Invoice' limit 1];
                            if(lstStep.size()>0){system.debug('in step');
                                for(HexaBPM__Step_Transition__c stptran :[select HexaBPM__SR_Status_Internal__c, HexaBPM__SR_Status_External__c, HexaBPM__Transition__r.HexaBPM__To__c, HexaBPM__Transition__r.HexaBPM__From__c from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__SR_Step__c=:lstStep[0].HexaBPM__SR_Step__c and HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Type__c = 'End' AND HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Rejection__c = false limit 1]){
                                    system.debug('in steptrans');if(stptran.HexaBPM__SR_Status_Internal__c!=null){objSR.HexaBPM__Internal_SR_Status__c = stptran.HexaBPM__SR_Status_Internal__c;} if(stptran.HexaBPM__SR_Status_External__c!=null){objSR.HexaBPM__External_SR_Status__c = stptran.HexaBPM__SR_Status_External__c;}
                                    break;
                                }                            
                            }
                        }
                        update objSr;
                        update objSr.HexaBPM__SR_Price_Items1__r;
                        
                        if(listInvoice <> null && listInvoice.size() > 0){
                            Invoice__c inv = new Invoice__c();
                            inv = listInvoice[0];
                            inv.Journal_Created__c = true;
                            inv.GL_Date__c = System.today();
                            inv.Status__c = 'Invoiced';
                            
                            Decimal invoiceAmnt = 0;
                            Decimal invoiceTaxAmnt = 0;
                            Decimal convertedInvoiceAmnt = 0;
                            Decimal convertedInvoiceTaxAmnt = 0;
                            Decimal discountAmnt = 0;
                            Decimal discountTaxAmnt = 0;
                            Decimal convertedDiscountAmnt = 0;
                            Decimal convertedDiscountTaxAmnt = 0;
                            Integer j = 1;
                            for(Invoice_Line_Item__c lineItemObj : inv.Invoice_Line_Items__r){
                                decimal taxAmount = lineItemObj.Tax_Amount__c != null ? lineItemObj.Tax_Amount__c : 0;
                                if(!lineItemObj.is_Discount__c){invoiceAmnt += lineItemObj.Amount__c;invoiceTaxAmnt += taxAmount;
                                    convertedInvoiceAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c; convertedInvoiceTaxAmnt += inv.Payment_Currency__c == 'USD' ? taxAmount * inv.Conversion_Rate__c : taxAmount;    }
                                else{ discountAmnt += lineItemObj.Amount__c; discountTaxAmnt += taxAmount;convertedDiscountAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c; convertedDiscountTaxAmnt += inv.Payment_Currency__c == 'USD' ? taxAmount * inv.Conversion_Rate__c : taxAmount;}
                                lineItemObj.Line_No__c = j; lineItemObj.Item_Reference__c = lineItemObj.Name;
                                lineItemObj.Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c; lineItemObj.Tax_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;
                                if(lineItemObj.is_Discount__c){lineItemObj.Discount_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c; lineItemObj.Taxable_Discount_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;    }
                                else{ lineItemObj.Discount_Amount_Converted__c = 0; lineItemObj.Taxable_Discount_Amount_Converted__c = 0;}
                                j++;
                            }
                            //listInvoiceLineItem.addAll(inv.Invoice_Line_Items__r);
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
                        
                        
                                //------------- Need to be discussed with Raghu and yogesh once -----
                            List<Related_Invoice_Receipt__c> recordsToInsert = new List<Related_Invoice_Receipt__c>();
                            
                            Decimal invoiceBalance = inv.Invoice_Balance__c;
                            Map<Id, Receipt__c> updateReceiptMap = new Map<Id, Receipt__c>();
                                
                            List<Related_Invoice_Receipt__c> applicationLst = new List<Related_Invoice_Receipt__c>();
                            for(Receipt__c eachReceipt : [SELECT Id, Receipt_Reference__c,Transaction_Reference__c,Authorization_Code__c,EFT_Reference_No__c, Receipt_Balance__c FROM Receipt__c
                                                          WHERE Receipt_Balance__c > 0 AND Payment_Currency__c = 'AED' AND Entity__c = :inv.Entity__c AND Journal_Created__c = true ORDER BY CreatedDate DESC]){
                                
                                if(invoiceBalance <= eachReceipt.Receipt_Balance__c){
                                    Related_Invoice_Receipt__c applicationObj = new Related_Invoice_Receipt__c(Applied__c = true); applicationObj.Journal_Created__c = true;applicationObj.Invoice__c = inv.Id;applicationObj.GL_Date__c = System.today(); applicationObj.Receipt__c = eachReceipt.Id;applicationObj.Applied_Date__c = System.today();applicationObj.Amount_Applied__c = invoiceBalance; applicationObj.ORACLE_Applied_Amount__c = invoiceBalance;applicationObj.ORACLE_Unapplied_Amount__c = eachReceipt.Receipt_Balance__c - invoiceBalance;applicationObj.Oracle_Converted_Applied_Amount__c = invoiceBalance; applicationObj.Oracle_Converted_UnApplied_Amount__c = eachReceipt.Receipt_Balance__c - invoiceBalance;applicationObj.Direction__c = 'From Invoice To Receipt';invoiceBalance = 0; applicationLst.add(applicationObj);
                                    break;
                                }else if(invoiceBalance > eachReceipt.Receipt_Balance__c){ Related_Invoice_Receipt__c applicationObj = new Related_Invoice_Receipt__c(Applied__c = true);applicationObj.Journal_Created__c = true;applicationObj.Invoice__c = inv.Id;applicationObj.Receipt__c = eachReceipt.Id;applicationObj.Applied_Date__c = System.today();applicationObj.GL_Date__c = System.today();applicationObj.Amount_Applied__c = eachReceipt.Receipt_Balance__c;applicationObj.ORACLE_Applied_Amount__c = eachReceipt.Receipt_Balance__c;applicationObj.ORACLE_Unapplied_Amount__c = 0; applicationObj.Oracle_Converted_Applied_Amount__c = eachReceipt.Receipt_Balance__c;applicationObj.Oracle_Converted_UnApplied_Amount__c = 0;applicationObj.Direction__c = 'From Invoice To Receipt';invoiceBalance = invoiceBalance - eachReceipt.Receipt_Balance__c;applicationLst.add(applicationObj);
                                }                          
                            }
                            system.debug('--->'+listInvoiceLineItem);
                            system.debug('--->'+applicationLst);
                            if(applicationLst.size() > 0 && invoiceBalance == 0){
                                inv.Invoice_Balance__c = 0;update inv;BM_JournalEntryEngine.invoiceCreationJournal(new List<Id>{inv.Id});insert applicationLst;List<Id> applicationIds = new List<Id>(); 
                                for(Related_Invoice_Receipt__c application : applicationLst){applicationIds.add(application.Id);}BM_JournalEntryEngine.receiptApplicationJournalLines(applicationIds);
                            }
                            else{inv.Oracle_Response_Message__c = 'Enough funds are not available';UPDATE inv;BM_JournalEntryEngine.invoiceCreationJournal(new List<Id>{inv.Id});}
                        }
                    }
            }catch(Exception ex){system.debug('ex.getLine' + ex.getLineNumber());system.debug('ex==>>' + ex.getMessage());String sMessage = ex.getMessage();Log__c objLog = new Log__c(); if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} else {objLog.Message__c = sMessage;} objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName(); insert objLog;Database.rollback(sp);return ex.getMessage();
            }
        }
        return 'Success';
    }
    
    public static void insertInvoiceLineItem(HexaBPM__Service_Request__c objSR, Id invoiceId, map<string, ID> mapTaxbleSRPwithILT, map<string, ID> mapNonTaxbleSRPwithILT){
        Invoice__c inv = [select GL_date__c from Invoice__c where id =: invoiceId];
        InputParameters_Class invObj;
        string strJsonRequestString;
        Date TodaysDate = system.today();
        string InvoiceDate = inv.GL_date__c.DAY()+'-'+inv.GL_date__c.Month()+'-'+inv.GL_date__c.Year();//TodaysDate.DAY()+'-'+TodaysDate.Month()+'-'+TodaysDate.Year();//'07-02-2018';//
        system.debug('InvoiceDate==>'+InvoiceDate);
        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        list<HexaBPM__Service_Request__c> lstSR = new list<HexaBPM__Service_Request__c>();
        
        list<LINE_REC_TYPE_CLASS> lstInvoiceLines = new list<LINE_REC_TYPE_CLASS>();
        list<LINE_REC_TYPE_CLASS> lstTaxableInvoiceLines = new list<LINE_REC_TYPE_CLASS>();
        list<LINE_REC_TYPE_CLASS> lstNonTaxableInvoiceLines = new list<LINE_REC_TYPE_CLASS>();
        list<LINE_REC_TYPE_CLASS> lstRefundTaxableLines = new list<LINE_REC_TYPE_CLASS>();
        list<LINE_REC_TYPE_CLASS> lstRefundNonTaxableLines = new list<LINE_REC_TYPE_CLASS>();
        if(objSR!=null)
            lstSR.add(objSR);
        
        for(HexaBPM__Service_Request__c objServiceRequest:lstSR){
            if(objServiceRequest.HexaBPM__SR_Price_Items1__r!=null){
                system.debug('LineItemsSize==>'+objServiceRequest.HexaBPM__SR_Price_Items1__r.size());
                for(HexaBPM__SR_Price_Item__c line:objServiceRequest.HexaBPM__SR_Price_Items1__r){
                    System.debug(line);
                    if(line.Is_Refund_Line__c){
                        String descr ='';
                        descr = line.Item_Type1__c;
                        
                        LINE_REC_TYPE_CLASS objRefundLine = new LINE_REC_TYPE_CLASS('0.0','0.0',line.Name,line.Id,String.valueOf(line.Markup_Amount__c),'5%',descr,null,
                                                                                    line.Service_Type__c,line.Department__c,'Default','Default','Default','Default', line.Revenue_Type__c);
                        
                        
                        if(objRefundLine.X5_AMOUNT!=null){lstRefundTaxableLines.add(objRefundLine);}
                            
                        decimal NonTaxableAmount;
                        if(line.Cost__c!=null)
                            NonTaxableAmount = line.Cost__c;
                        if(line.Cancellation_Fee__c!=null){NonTaxableAmount = NonTaxableAmount + line.Cancellation_Fee__c;}
                            
                        
                        if(NonTaxableAmount!=null && NonTaxableAmount!=0){
                            objRefundLine = new LINE_REC_TYPE_CLASS('0.0','0.0',line.Name,line.Id,String.valueof(NonTaxableAmount),'Exempt 0%',line.Item_Type1__c,null,
                                                                    line.Service_Type__c,line.Department__c,'Default','Default','Default','Default', line.Revenue_Type__c);
                            lstRefundNonTaxableLines.add(objRefundLine);
                        }
                    }else{String amt = ''; String taxamt = '0';
                        if(line.Markup_Amount__c==null && line.Cost__c==null && line.HexaBPM__Price__c!=null){amt = String.valueof(line.HexaBPM__Price__c);} 
                        else {amt = String.valueOf(line.Markup_Amount__c);}
                        if(line.Tax_Amount__c!=null){taxamt = String.valueof(line.Tax_Amount__c);}
                         LINE_REC_TYPE_CLASS objInvoiceLine = new LINE_REC_TYPE_CLASS('0.0','0.0',line.Name,line.Id,amt,'5%',line.Item_Type1__c,null,line.Service_Type__c,line.Department__c,'Default','Default','Default','Default', line.Revenue_Type__c);
                        if(objInvoiceLine.X5_AMOUNT!=null && Decimal.valueof(objInvoiceLine.X5_AMOUNT)>0){lstTaxableInvoiceLines.add(objInvoiceLine);}
                        if(line.Cost__c!=null && line.Cost__c>0){ objInvoiceLine = new LINE_REC_TYPE_CLASS('0.0','0.0',line.Name,line.Id,String.valueof(line.Cost__c),'Exempt 0%',line.Item_Type1__c,null,line.Service_Type__c,line.Department__c,'Default','Default','Default','Default', line.Revenue_Type__c);
                            lstNonTaxableInvoiceLines.add(objInvoiceLine);
                        }
                    }
                }
            }
            
            String invType = '';
            if(objServiceRequest.HexaBPM__SR_Price_Items1__r.size() > 0){
                invType = objServiceRequest.HexaBPM__SR_Price_Items1__r[0].Invoice_Type1__c;
            }
            invObj = new InputParameters_Class(objServiceRequest.Name, objServiceRequest.Id, objServiceRequest.HexaBPM__Customer__r.Oracle_Party_Id__c,'Access' ,objServiceRequest.RecordType.Name,
                                               invType,InvoiceDate,objServiceRequest.HexaBPM__Customer__r.Oracle_Site_Id__c,'Invoice','Immediate','AED','WALLET',null);
            
        }
        system.debug('lstRefundTaxableLines==>'+lstRefundTaxableLines.size()+' == '+lstRefundTaxableLines);
        system.debug('lstTaxableInvoiceLines==>'+lstTaxableInvoiceLines.size()+' == '+lstTaxableInvoiceLines);
        system.debug('lstRefundNonTaxableLines==>'+lstRefundNonTaxableLines.size()+' == '+lstRefundNonTaxableLines);
        system.debug('lstNonTaxableInvoiceLines==>'+lstNonTaxableInvoiceLines.size()+' == '+lstNonTaxableInvoiceLines);
        
        if(lstRefundTaxableLines.size()>0 && lstTaxableInvoiceLines.size()>0){
            for(LINE_REC_TYPE_CLASS RefundInvoice:lstRefundTaxableLines){
                for(LINE_REC_TYPE_CLASS MainInvoice:lstTaxableInvoiceLines){
                    if((Decimal.valueof(RefundInvoice.X5_AMOUNT)*-1) <= Decimal.valueof(MainInvoice.X5_AMOUNT)){ MainInvoice.X5_AMOUNT = String.valueOf( Decimal.valueof(MainInvoice.X5_AMOUNT) + Decimal.valueof(RefundInvoice.X5_AMOUNT) ); MainInvoice.X4_TAX_CODE = '5%';
                        break;
                    }
                }
            }
        }
        if(lstRefundNonTaxableLines.size()>0 && lstNonTaxableInvoiceLines.size()>0){
            for(LINE_REC_TYPE_CLASS RefundInvoice:lstRefundNonTaxableLines){
                for(LINE_REC_TYPE_CLASS MainInvoice:lstNonTaxableInvoiceLines){
                    if((Decimal.valueof(RefundInvoice.X5_AMOUNT) * -1) <= Decimal.valueof(MainInvoice.X5_AMOUNT)){ MainInvoice.X5_AMOUNT = String.valueof(Decimal.valueof(MainInvoice.X5_AMOUNT) + Decimal.valueof(RefundInvoice.X5_AMOUNT));MainInvoice.X4_TAX_CODE = 'Exempt 0%'; break;
                    }
                }
            }
        }
        
        // create invoice line item list
        if( invoiceId <> null) {
            // create taxble line item
            for (LINE_REC_TYPE_CLASS objLINE_REC_TYPE_CLASS : lstTaxableInvoiceLines) { listInvoiceLineItem.add(mapInvoiceLineItem(objLINE_REC_TYPE_CLASS,true, invoiceId, mapTaxbleSRPwithILT.get(objLINE_REC_TYPE_CLASS.X6_ITEM_SFID) ));
            }
            // create non-taxble line item            
            for (LINE_REC_TYPE_CLASS objLINE_REC_TYPE_CLASS : lstNonTaxableInvoiceLines) {listInvoiceLineItem.add(mapInvoiceLineItem(objLINE_REC_TYPE_CLASS,false, invoiceId, mapNonTaxbleSRPwithILT.get(objLINE_REC_TYPE_CLASS.X6_ITEM_SFID)  ));}
        }
        if(!listInvoiceLineItem.isEmpty()){UPSERT listInvoiceLineItem;
        }
    }
    
    /*public static string pushToOracle(List<String> srIDs){
        pricingItemMap = new Map<Id,HexaBPM__SR_Price_Item__c>();
        map<string, ID> mapTaxbleSRPwithILT = new map<string, ID>();
        map<string, ID> mapNonTaxbleSRPwithILT = new map<string, ID>();
        Id invoiceId;
        if(srIDs <> null && srIDs.size() > 0){
            try{
                List<Invoice__c> listInvoice = new List<Invoice__c>();
                listInvoice = [SELECT Id,Name,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,GL_Date__c,Entity__r.Oracle_Party_Id__c,Invoice_Class__c,Oracle_Invoice_Type__c,Oracle_GL_Date__c, Converted_Invoice_Balance__c,Entity__c,
                                      Payment_Term__c,Payment_Currency__c,Status__c,Invoice_Amount__c,Tax_Amount__c,Discount_Amount__c,Discount_Tax_Amount__c,Converted_Discount_Amount__c,Converted_Discount_Tax_Amount__c,Converted_Invoice_Amount__c,Converted_Tax_Amount__c,
                               (SELECT Id,Name,Taxable_Discount_Amount__c,Discount_Amount__c,Item_Reference__c,Amount__c,Total_Amount__c,Revenue_Type__c,
                                Service_Type__c,Schools__c,Department__c,Is_Discount__c,SR_Price_Item__c,Tax_Amount__c,Item_Description__c,Line_Description__c,Tax__c, Is_Taxable__c
                                FROM Invoice_Line_Items__r WHERE RECORDTYPE.Name = 'Invoice Line Item') FROM Invoice__c WHERE Service_Request__c IN: srIDs LIMIT 1];
                
                if(listInvoice <> null && listInvoice.size() > 0) {
                    invoiceId = listInvoice[0].id;
                    for(Invoice_Line_Item__c eachLine : listInvoice[0].Invoice_Line_Items__r){
                        if(eachLine.Is_Taxable__c)
                            mapTaxbleSRPwithILT.put(eachLine.SR_Price_Item__c, eachLine.id);
                        else
                            mapNonTaxbleSRPwithILT.put(eachLine.SR_Price_Item__c, eachLine.id);
                    }
                }
                
                //------- ,Department__c,Invoice_Type__c,Item_Type1__c,Revenue_Type__c,Service_Type__c
                for(HexaBPM__Service_Request__c SR:[Select Id,Name,HexaBPM__Customer__r.Oracle_Site_Id__c,HexaBPM__SR_Template__c,HexaBPM__SR_Template__r.Invoice_Transaction_Type__c,HexaBPM__Customer__c,HexaBPM__Customer__r.Oracle_Party_Id__c,RecordType.Name, Oracle_Credit_Number__c, Oracle_Invoice_Number__c, Service_Request_Name__c,
                    (Select Id,Name,HexaBPM__Status__c,HexaBPM__Price__c,Tax_Amount__c,Invoice_Type1__c,HexaBPM__Pricing_Line__c,HexaBPM__Product__c,HexaBPM__Product__r.Name,HexaBPM__Pricing_Line__r.Name,Is_Refund_Line__c,Oracle_Response__c,Cost__c,Markup_Amount__c,Cancellation_Fee__c 
                    ,Department__c,Item_Type1__c,Revenue_Type__c,Service_Type__c,Service_Class__c
                    from HexaBPM__SR_Price_Items1__r where HexaBPM__Status__c!='Invoiced' and HexaBPM__Status__c!='Cancelled') 
                    from HexaBPM__Service_Request__c where Id IN: srIDs and HexaBPM__Customer__r.Is_ADGM_Company__c = false LIMIT 1]){
                        // put all pricing item in map
                        //for(HexaBPM__SR_Price_Item__c eachItem : SR.HexaBPM__SR_Price_Items1__r){
                        //    pricingItemMap.put(eachItem.id, eachItem);
                        //}
                        
                        String jsonBody = ConstructInvoicePayload(SR, invoiceId, mapTaxbleSRPwithILT, mapNonTaxbleSRPwithILT);
                        
                        for(HexaBPM__SR_Price_Item__c SRP: SR.HexaBPM__SR_Price_Items1__r){
                            SRP.HexaBPM__Status__c = 'Invoiced';
                            //SRP.Oracle_Response__c = respObj.P_OP_RETURN_STS;
                        }
                        // Issue Fix- status change to submitted after service request is closed- shagufta 05/04/2021
                        if(SR.Service_Request_Name__c=='Sales and Promotion Permit'){
                            List<HexaBPM__Step__c> lstStep = [SELECT id, HexaBPM__SR_Step__c,HexaBPM__Status__c FROM HexaBPM__Step__c WHERE HexaBPM__SR__c=:SR.Id AND HexaBPM__Summary__c='Generate Permit & Invoice' limit 1];
                            if(lstStep.size()>0){
                                system.debug('in step');
                                for(HexaBPM__Step_Transition__c stptran :[select HexaBPM__SR_Status_Internal__c, HexaBPM__SR_Status_External__c, HexaBPM__Transition__r.HexaBPM__To__c, HexaBPM__Transition__r.HexaBPM__From__c from HexaBPM__Step_Transition__c where HexaBPM__Transition__c!=null and HexaBPM__SR_Step__c=:lstStep[0].HexaBPM__SR_Step__c and HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Type__c = 'End' AND HexaBPM__Transition__r.HexaBPM__To__r.HexaBPM__Rejection__c = false limit 1]){
                                    system.debug('in steptrans');
                                    if(stptran.HexaBPM__SR_Status_Internal__c!=null)
                                        SR.HexaBPM__Internal_SR_Status__c = stptran.HexaBPM__SR_Status_Internal__c;
                                    if(stptran.HexaBPM__SR_Status_External__c!=null)
                                        SR.HexaBPM__External_SR_Status__c = stptran.HexaBPM__SR_Status_External__c;
                                    break;
                                }                            
                            }
                        }
                        update SR;
                        update SR.HexaBPM__SR_Price_Items1__r;
                        
                        if(listInvoice <> null && listInvoice.size() > 0){
                            Invoice__c inv = new Invoice__c();
                            inv = listInvoice[0];
                            inv.Journal_Created__c = true;
                            inv.Status__c = 'Invoiced';
                            
                        Decimal invoiceAmnt = 0;
                        Decimal invoiceTaxAmnt = 0;
                        Decimal convertedInvoiceAmnt = 0;
                        Decimal convertedInvoiceTaxAmnt = 0;
                        Decimal discountAmnt = 0;
                        Decimal discountTaxAmnt = 0;
                        Decimal convertedDiscountAmnt = 0;
                        Decimal convertedDiscountTaxAmnt = 0;
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
                        listInvoiceLineItem.add(inv.Invoice_Line_Items__r);
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
                        
                        
                            List<Related_Invoice_Receipt__c> recordsToInsert = new List<Related_Invoice_Receipt__c>();
                                                   
                            	
                            Map<String,Receipt__c> receiptMap = new Map<String,Receipt__c>();
                            Decimal invoiceBalance = inv.Invoice_Balance__c;
                            Map<Id, Receipt__c> updateReceiptMap = new Map<Id, Receipt__c>();
                            
                            List<Related_Invoice_Receipt__c> applicationLst = new List<Related_Invoice_Receipt__c>();
                            for(Receipt__c eachReceipt : [SELECT Id, Receipt_Reference__c,Transaction_Reference__c,Authorization_Code__c,EFT_Reference_No__c, Receipt_Balance__c FROM Receipt__c
                                                         WHERE Receipt_Balance__c > 0 AND Payment_Currency__c = 'AED' AND Entity__c = :inv.Entity__c AND Journal_Created__c = true ORDER BY CreatedDate DESC]){
                                receiptMap.put(eachReceipt.Receipt_Reference__c, eachReceipt);
                                if(invoiceBalance < eachReceipt.Receipt_Balance__c){
                                    Related_Invoice_Receipt__c applicationObj = new Related_Invoice_Receipt__c();
                                    applicationObj.Invoice__c = inv.Id;
                                    applicationObj.Receipt__c = eachReceipt.Id;
                                    applicationObj.Applied_Date__c = System.today();
                                    applicationObj.Amount_Applied__c = invoiceBalance;
                                    applicationObj.ORACLE_Applied_Amount__c = invoiceBalance;
                                    applicationObj.ORACLE_Unapplied_Amount__c = eachReceipt.Receipt_Balance__c - invoiceBalance;
                                    applicationObj.Oracle_Converted_Applied_Amount__c = invoiceBalance;
                                    applicationObj.Oracle_Converted_UnApplied_Amount__c = eachReceipt.Receipt_Balance__c - invoiceBalance;
                                    applicationObj.Direction__c = 'From Invoice To Receipt';
                                    invoiceBalance = 0;    
                                    applicationLst.add(applicationObj);
                                    break;
                                }else if(invoiceBalance > eachReceipt.Receipt_Balance__c){
                                    Related_Invoice_Receipt__c applicationObj = new Related_Invoice_Receipt__c();
                                    applicationObj.Invoice__c = inv.Id;
                                    applicationObj.Receipt__c = eachReceipt.Id;
                                    applicationObj.Applied_Date__c = System.today();
                                    applicationObj.Amount_Applied__c = invoiceBalance;
                                    applicationObj.ORACLE_Applied_Amount__c = eachReceipt.Receipt_Balance__c;
                                    applicationObj.ORACLE_Unapplied_Amount__c = 0;
                                    applicationObj.Oracle_Converted_Applied_Amount__c = eachReceipt.Receipt_Balance__c;
                                    applicationObj.Oracle_Converted_UnApplied_Amount__c = 0;
                                    invoiceBalance = invoiceBalance - eachReceipt.Receipt_Balance__c;
                                    applicationLst.add(applicationObj);
                                }                          
                            }
                            system.debug('--->'+listInvoiceLineItem);
                            system.debug('--->'+applicationLst);
                            if(recordsToInsert.size() > 0 && invoiceBalance == 0){
                                if(listInvoiceLineItem <> null && listInvoiceLineItem.size() > 0)
                                	upsert listInvoiceLineItem;
                                
                                inv.Invoice_Balance__c = 0;
                                update inv;
                                BM_JournalEntryEngine.invoiceCreationJournal(new List<Id>{inv.Id});
                                
                                insert applicationLst;
                                List<Id> applicationIds = new List<Id>(); 
                                for(Related_Invoice_Receipt__c application : applicationLst){applicationIds.add(application.Id);}
                                BM_JournalEntryEngine.receiptApplicationJournalLines(applicationIds);
                                
                                
                            }else{
                                inv.Oracle_Response_Message__c = 'Enough funds are not available';
                                UPDATE inv;
                                BM_JournalEntryEngine.invoiceCreationJournal(new List<Id>{inv.Id});
                                
                            }
                        }
                    }  
            } catch(Exception e) {
                system.debug('----->'+e.getMessage());
                return e.getMessage();
            }
            return 'Success';
        }
        
        
        return 'Success';
    }*/
    // For Invoice and Invoice Line items //temp Invoice_Amount__c
    public static string pushToOracleInvoice(List<String> invIDs){
        if(invIDs <> null && invIDs.size() > 0){
            try{
                for(Invoice__c inv : [SELECT Id,Name,Source_System__c,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,GL_Date__c,Oracle_GL_Date__c,Entity__r.Oracle_Party_Id__c,Invoice_Class__c,Oracle_Invoice_Type__c,Source_Invoice_Id__c,Transaction_Type__c,Conversion_Rate__c,
                                      Payment_Term__c,Payment_Currency__c,Status__c,Total_Invoice_Amount__c,Invoice_Amount__c,Tax_Amount__c,Discount_Amount__c,Discount_Tax_Amount__c,Converted_Discount_Amount__c,Converted_Discount_Tax_Amount__c,Converted_Invoice_Amount__c,Converted_Tax_Amount__c,Converted_Invoice_Balance__c,
                                      (SELECT Id,Name,Taxable_Discount_Amount__c,Discount_Amount__c,Item_Reference__c,Amount__c,Total_Amount__c,Revenue_Type__c,Service_Type__c,Schools__c,Course_Type__c,Department__c,Is_Discount__c,
                                      Tax_Amount__c,Item_Description__c,Line_Description__c,Tax__c FROM Invoice_Line_Items__r WHERE RECORDTYPE.Name = 'Invoice Line Item' AND Status__c != 'Cancelled') FROM Invoice__c WHERE Id IN: invIDs and Service_Request__c = null LIMIT 1]){
                    

                    //List<Related_Invoice_Receipt__c> relatedReceipts = new List<Related_Invoice_Receipt__c>();
                    //if(respObj.P_OP_RETURN_STS == 'S' && string.isNotBlank(respObj.P_OP_INV_NUM)){
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
                        Integer j = 1;
                        for(Invoice_Line_Item__c lineItemObj : inv.Invoice_Line_Items__r){
                            if(!lineItemObj.is_Discount__c){invoiceAmnt += lineItemObj.Amount__c;invoiceTaxAmnt += lineItemObj.Tax_Amount__c;convertedInvoiceAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;convertedInvoiceTaxAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;    
                            }else{discountAmnt += lineItemObj.Amount__c;discountTaxAmnt += lineItemObj.Tax_Amount__c;convertedDiscountAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;convertedDiscountTaxAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;
                            }
                            lineItemObj.Line_No__c = j;lineItemObj.Item_Reference__c = lineItemObj.Name;lineItemObj.Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;lineItemObj.Tax_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;
                            if(lineItemObj.is_Discount__c){lineItemObj.Discount_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;lineItemObj.Taxable_Discount_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;    
                            }else{lineItemObj.Discount_Amount_Converted__c = 0;lineItemObj.Taxable_Discount_Amount_Converted__c = 0;}
                            
                            j++;
                        }
                        listInvoiceLineItem.add(inv.Invoice_Line_Items__r); inv.Invoice_Balance__c = invoiceAmnt + invoiceTaxAmnt + discountAmnt + discountTaxAmnt;inv.Converted_Invoice_Balance__c = convertedInvoiceAmnt + convertedInvoiceTaxAmnt + convertedDiscountAmnt + convertedDiscountTaxAmnt;inv.Converted_Invoice_Amount__c = convertedInvoiceAmnt; inv.Converted_Discount_Amount__c = convertedDiscountAmnt;inv.Converted_Discount_Tax_Amount__c = convertedDiscountTaxAmnt; inv.Converted_Tax_Amount__c = convertedInvoiceTaxAmnt;inv.Invoice_Amount__c = invoiceAmnt; inv.Discount_Amount__c = discountAmnt; inv.Discount_Tax_Amount__c = discountTaxAmnt; inv.Tax_Amount__c = invoiceTaxAmnt;
                        
						update inv;update inv.Invoice_Line_Items__r;BM_JournalEntryEngine.invoiceCreationJournal(new List<Id>{inv.Id});return 'SUCCESS';
                }
            } catch(Exception ex){
                String sMessage = ex.getMessage();
                Log__c objLog = new Log__c();
                if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);
                } else {objLog.Message__c = sMessage;}//end if
                
                objLog.Line_Number__c = ex.getLineNumber();
                objLog.Stack_Trace__c =  ex.getStackTraceString();
                objLog.Type_Name__c = ex.getTypeName();
                insert objLog;
                return ex.getMessage();
            }
             return null;
        }
        return null;
    }
    
    
    // For Invoice and Invoice Line items future // temp Invoice_Amount__c,
    @Future(callout=true)
    public static void pushToOracleInvoice_Future(List<String> invIDs){
        if(invIDs <> null && invIDs.size() > 0){
            try{
                List<Invoice__c> listInvoice = new List<Invoice__c>();
                List<Invoice_Line_Item__c> listInvoiceLineItem = new List<Invoice_Line_Item__c>();
                //List<Related_Invoice_Receipt__c> allRelatedReceipts = new List<Related_Invoice_Receipt__c>();
                List<Id> invoiceIds = new List<Id>();
                for(Invoice__c inv : [SELECT Id,Name,Source_System__c,Entity__r.Oracle_Site_Id__c,Description__c,Invoice_Type__c,Invoice_Date__c,GL_Date__c,Oracle_GL_Date__c,Entity__r.Oracle_Party_Id__c,Invoice_Class__c,Oracle_Invoice_Type__c,Source_Invoice_Id__c,Transaction_Type__c,Conversion_Rate__c,
                                      Payment_Term__c,Payment_Currency__c,Status__c,Total_Invoice_Amount__c,Invoice_Amount__c,Tax_Amount__c,Discount_Amount__c,Discount_Tax_Amount__c,Converted_Discount_Amount__c,Converted_Discount_Tax_Amount__c,Converted_Invoice_Amount__c,Converted_Tax_Amount__c,Converted_Invoice_Balance__c,
                                      (SELECT Id,Name,Taxable_Discount_Amount__c,Discount_Amount__c,Item_Reference__c,Amount__c,Total_Amount__c,Is_Discount__c,
                                      Tax_Amount__c,Item_Description__c,Line_Description__c,Tax__c,Department__c,Service_Type__c,Course_Type__c,Schools__c,Quantity__c,Revenue_Type__c FROM Invoice_Line_Items__r WHERE RECORDTYPE.Name = 'Invoice Line Item' AND Status__c != 'Cancelled') FROM Invoice__c WHERE Id IN: invIDs and Service_Request__c = null LIMIT 1]){
                    
                    	inv.Journal_Created__c = true;
                        inv.Status__c = 'Invoiced';
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
                            if(!lineItemObj.is_Discount__c){invoiceAmnt += lineItemObj.Amount__c;invoiceTaxAmnt += lineItemObj.Tax_Amount__c;convertedInvoiceAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;convertedInvoiceTaxAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;    }
                            else{discountAmnt += lineItemObj.Amount__c;discountTaxAmnt += lineItemObj.Tax_Amount__c;convertedDiscountAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;convertedDiscountTaxAmnt += inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c; }
                            lineItemObj.Line_No__c = i;lineItemObj.Item_Reference__c = lineItemObj.Name;lineItemObj.Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c; lineItemObj.Tax_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Tax_Amount__c * inv.Conversion_Rate__c : lineItemObj.Tax_Amount__c;
                            if(lineItemObj.is_Discount__c){lineItemObj.Discount_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c; lineItemObj.Taxable_Discount_Amount_Converted__c = inv.Payment_Currency__c == 'USD' ? lineItemObj.Amount__c * inv.Conversion_Rate__c : lineItemObj.Amount__c;    }
                            else{lineItemObj.Discount_Amount_Converted__c = 0;lineItemObj.Taxable_Discount_Amount_Converted__c = 0;}
                            
                            i++;
                        }
                        listInvoiceLineItem.add(inv.Invoice_Line_Items__r); inv.Invoice_Balance__c = invoiceAmnt + invoiceTaxAmnt + discountAmnt + discountTaxAmnt; inv.Converted_Invoice_Balance__c = convertedInvoiceAmnt + convertedInvoiceTaxAmnt + convertedDiscountAmnt + convertedDiscountTaxAmnt; inv.Converted_Invoice_Amount__c = convertedInvoiceAmnt; inv.Converted_Discount_Amount__c = convertedDiscountAmnt; inv.Converted_Discount_Tax_Amount__c = convertedDiscountTaxAmnt; inv.Converted_Tax_Amount__c = convertedInvoiceTaxAmnt; inv.Invoice_Amount__c = invoiceAmnt; inv.Discount_Amount__c = discountAmnt; inv.Discount_Tax_Amount__c = discountTaxAmnt; inv.Tax_Amount__c = invoiceTaxAmnt;listInvoice.add(inv);invoiceIds.add(inv.Id);
                }
                
                if(listInvoice <> null && listInvoice.size() > 0){update listInvoice; BM_JournalEntryEngine.invoiceCreationJournal(invoiceIds);}
                
                if(listInvoiceLineItem <> null && listInvoiceLineItem.size() > 0){update listInvoiceLineItem;}

                /*if(allRelatedReceipts.size() > 0){
                    update allRelatedReceipts;
                } */
            } catch(Exception ex){
                system.debug(ex.getLineNumber());
                String sMessage = ex.getMessage();
                Log__c objLog = new Log__c();
                if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);
                } else {objLog.Message__c = sMessage;}//end if
                
                objLog.Line_Number__c = ex.getLineNumber();
                objLog.Stack_Trace__c =  ex.getStackTraceString();
                objLog.Type_Name__c = ex.getTypeName();
                //objLog.User_Email__c = UserInfo.getUserEmail();
                insert objLog;
            }
        }   
    }

    public static string ConstructInvoicePayload(Invoice__c objInv){
        list<LINE_REC_TYPE_CLASS> lstInvoiceLines = new list<LINE_REC_TYPE_CLASS>();
        if(objInv.Invoice_Line_Items__r.size() > 0){
            for(Invoice_Line_Item__c InvLI : objInv.Invoice_Line_Items__r){
                String taxableDiscAmt = InvLI.Taxable_Discount_Amount__c != null ? String.valueof(InvLI.Taxable_Discount_Amount__c* -1) : '0.0';String discAmt = InvLI.Discount_Amount__c != null ? String.valueOf(InvLI.Discount_Amount__c * -1) : '0.0';
                 String amount = InvLI.Total_Amount__c != null ? String.valueof(InvLI.Total_Amount__c) : '0.0';String taxAmount = InvLI.Tax__c; String itemRef = InvLI.Item_Reference__c != null ? InvLI.Item_Reference__c : InvLI.Name;String itemDesc =  InvLI.Item_Description__c != null && InvLI.Item_Description__c != 'None' ? InvLI.Item_Description__c : InvLI.Line_Description__c;String serviceType = InvLI.Service_Type__c;
                if(InvLi.Is_Discount__c){serviceType = 'Discount-'+ InvLI.Service_Type__c;}
                lstInvoiceLines.add(new LINE_REC_TYPE_CLASS(taxableDiscAmt,discAmt,itemRef,InvLI.Id,amount,taxAmount,itemDesc,InvLI.Line_Description__c,serviceType,InvLI.Department__c,InvLI.Course_Type__c,'Default',InvLI.Schools__c,'Default', InvLI.Revenue_Type__c));
            }   
        }
        //InputParameters_Class(String INV_SR_REF, String SFID, String ORA_CUST_ID, String INV_DESC, String INV_TYPE, String INV_DATE, String ORG_ID, String INV_CLASS, String PAYMENT_TERM, String INVCURRENCY, String INV_STATUS, String RECEIPT_NO)
        String DateVal = '';
        if(objInv.GL_Date__c != null){
            DateVal = objInv.GL_Date__c.DAY()+'-'+objInv.GL_Date__c.Month()+'-'+objInv.GL_Date__c.Year();
        } else if(objInv.Invoice_Date__c != null){DateVal = objInv.Invoice_Date__c.DAY()+'-'+objInv.Invoice_Date__c.Month()+'-'+objInv.Invoice_Date__c.Year();
        } else {DateVal = Date.Today().DAY()+'-'+Date.Today().Month()+'-'+Date.Today().Year();
        } 
        
        
        String invoiceNo = '';
        invoiceNo = (objInv.Source_Invoice_Id__c == null || objInv.Source_Invoice_Id__c == '') ? objInv.Name :  objInv.Source_Invoice_Id__c;

        List<String> oracleReceipts = new List<String>();
        Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        for(Related_Invoice_Receipt__c eachRobj : [SELECT Id, Receipt__r.Transaction_Reference__c, Receipt__r.EFT_Reference_No__c, Receipt__r.Payment_Method__c, Receipt__r.Oracle_Receipt_Id__c, Receipt__r.Receipt_Reference__c FROM Related_Invoice_Receipt__c WHERE Invoice__c =: objInv.id AND Direction__c =: 'From Invoice To Receipt' ORDER BY Receipt__r.Receipt_Reference__c ASC])
        {
            //oracleReceipts.add(eachRobj.Receipt__r.Oracle_Receipt_Id__c);
            
            String transRef = '';
            if(eachRobj.Receipt__r.Payment_Method__c != null){
                if(eachRobj.Receipt__r.Payment_Method__c.contains('Card') && eachRobj.Receipt__r.Authorization_Code__c != null){
                    transRef = eachRobj.Receipt__r.Authorization_Code__c;
                    if(isSandbox){Integer randomNumber = Integer.valueof((Math.random() * 10000));transRef = transRef+randomNumber;}
                } 
                else if(eachRobj.Receipt__r.Payment_Method__c == 'Electronic Funds Transfer' && eachRobj.Receipt__r.EFT_Reference_No__c != null){transRef = eachRobj.Receipt__r.EFT_Reference_No__c;
                } else {transRef = eachRobj.Receipt__r.Transaction_Reference__c;
                }
            }else {transRef = eachRobj.Receipt__r.Transaction_Reference__c;
            }
            oracleReceipts.add(transRef);
        }
        
        String payTerm = objInv.Payment_Term__c == 'IMMEDIATE' ? 'Immediate' : objInv.Payment_Term__c;
        if(String.isNotBlank(payTerm) && payTerm == 'On or before 31st January'){ payTerm = 'On/Before 31Jan';}
        system.debug('payterm==>>' + payTerm);
    system.debug('System.Label.DaysPaymentTerm==>>' + System.Label.DaysPaymentTerm);
        //if payment term contains 'days', replace it with 'Net'
        if(payTerm.contains(System.Label.DaysPaymentTerm)){payTerm = payTerm.replace(System.Label.DaysPaymentTerm, 'Net');}

        InputParameters_Class invObj = new InputParameters_Class(invoiceNo,objInv.Id,objInv.Entity__r.Oracle_Party_Id__c,objInv.Source_System__c,objInv.Description__c,
                                                                     objInv.Oracle_Invoice_Type__c,//(objInv.Oracle_Invoice_Type__c != null ? objInv.Oracle_Invoice_Type__c.toUpperCase() : objInv.Oracle_Invoice_Type__c),
                                                                     DateVal,objInv.Entity__r.Oracle_Site_Id__c,
                                                                     objInv.Invoice_Class__c,
                                                                     payTerm,//(objInv.Payment_Term__c != null ? objInv.Payment_Term__c.toUpperCase() : objInv.Payment_Term__c),
                                                                     objInv.Payment_Currency__c,
                                                                     objInv.Transaction_Type__c,
                                                                     String.join(oracleReceipts, ',')); //objInv.Status__c

        P_LINE_TBL_CLASS lineTblClass = new P_LINE_TBL_CLASS();
        lineTblClass.LINE_REC_TYPE.addAll(lstInvoiceLines);
        invObj.P_LINE_TBL = lineTblClass;
        CreateInvoice_Class obj = new CreateInvoice_Class();
        obj.InputParameters = invObj;
        CreateInvoice_Wrapper wrapperObj = new CreateInvoice_Wrapper();
        wrapperObj.CreateInvoice = obj;
        String s = JSON.serialize(wrapperObj);
        reqPara objClass = new reqPara();
        objClass.P_SR_Header = s;
        //invObj = constructFinalWrapper(invObj,lineItemList);
        system.debug(objClass);
        return JSON.serialize(objClass);
    }

    /*public static string ConstructInvoicePayload(HexaBPM__Service_Request__c objSR, Id invoiceId, map<string, ID> mapTaxbleSRPwithILT, map<string, ID> mapNonTaxbleSRPwithILT){
        
        Invoice__c inv = [select GL_date__c from Invoice__c where id =: invoiceId];
        InputParameters_Class invObj;
        string strJsonRequestString;
        Date TodaysDate = system.today();
        string InvoiceDate = inv.GL_date__c.DAY()+'-'+inv.GL_date__c.Month()+'-'+inv.GL_date__c.Year();//TodaysDate.DAY()+'-'+TodaysDate.Month()+'-'+TodaysDate.Year();//'07-02-2018';//
        system.debug('InvoiceDate==>'+InvoiceDate);
        HexaBPM__Service_Request__c SR = new HexaBPM__Service_Request__c();
        list<HexaBPM__Service_Request__c> lstSR = new list<HexaBPM__Service_Request__c>();
        
        list<LINE_REC_TYPE_CLASS> lstInvoiceLines = new list<LINE_REC_TYPE_CLASS>();
        list<LINE_REC_TYPE_CLASS> lstTaxableInvoiceLines = new list<LINE_REC_TYPE_CLASS>();
        list<LINE_REC_TYPE_CLASS> lstNonTaxableInvoiceLines = new list<LINE_REC_TYPE_CLASS>();
        list<LINE_REC_TYPE_CLASS> lstRefundTaxableLines = new list<LINE_REC_TYPE_CLASS>();
        list<LINE_REC_TYPE_CLASS> lstRefundNonTaxableLines = new list<LINE_REC_TYPE_CLASS>();
        if(objSR!=null)
            lstSR.add(objSR);

        for(HexaBPM__Service_Request__c objServiceRequest:lstSR){
            if(objServiceRequest.HexaBPM__SR_Price_Items1__r!=null){
              system.debug('LineItemsSize==>'+objServiceRequest.HexaBPM__SR_Price_Items1__r.size());
                for(HexaBPM__SR_Price_Item__c line:objServiceRequest.HexaBPM__SR_Price_Items1__r){
                    System.debug(line);
                    if(line.Is_Refund_Line__c){
                        String descr ='';
                            descr = line.Item_Type1__c;
                        
                        LINE_REC_TYPE_CLASS objRefundLine = new LINE_REC_TYPE_CLASS('0.0','0.0',line.Name,line.Id,String.valueOf(line.Markup_Amount__c),'5%',descr,null,
                        line.Service_Type__c,line.Department__c,'Default','Default','Default','Default', line.Revenue_Type__c);
                        

                        if(objRefundLine.X5_AMOUNT!=null)
                            lstRefundTaxableLines.add(objRefundLine);
                        decimal NonTaxableAmount;
                        if(line.Cost__c!=null)
                            NonTaxableAmount = line.Cost__c;
                        if(line.Cancellation_Fee__c!=null)
                            NonTaxableAmount = NonTaxableAmount + line.Cancellation_Fee__c;

                        if(NonTaxableAmount!=null && NonTaxableAmount!=0){
                            objRefundLine = new LINE_REC_TYPE_CLASS('0.0','0.0',line.Name,line.Id,String.valueof(NonTaxableAmount),'Exempt 0%',line.Item_Type1__c,null,
                            line.Service_Type__c,line.Department__c,'Default','Default','Default','Default', line.Revenue_Type__c);
                            lstRefundNonTaxableLines.add(objRefundLine);
                        }
                    }else{
                        String amt = '';
                        if(line.Markup_Amount__c==null && line.Cost__c==null && line.HexaBPM__Price__c!=null){
                            amt = String.valueof(line.HexaBPM__Price__c);
                        } else {
                            amt = String.valueOf(line.Markup_Amount__c);
                        }

                        String taxamt = '0';
                        if(line.Tax_Amount__c!=null)
                            taxamt = String.valueof(line.Tax_Amount__c);
                            
                        LINE_REC_TYPE_CLASS objInvoiceLine = new LINE_REC_TYPE_CLASS('0.0','0.0',line.Name,line.Id,amt,'5%',line.Item_Type1__c,null,
                        line.Service_Type__c,line.Department__c,'Default','Default','Default','Default', line.Revenue_Type__c);

                        if(objInvoiceLine.X5_AMOUNT!=null && Decimal.valueof(objInvoiceLine.X5_AMOUNT)>0)
                            lstTaxableInvoiceLines.add(objInvoiceLine);
                        if(line.Cost__c!=null && line.Cost__c>0){
                            objInvoiceLine = new LINE_REC_TYPE_CLASS('0.0','0.0',line.Name,line.Id,String.valueof(line.Cost__c),'Exempt 0%',line.Item_Type1__c,null,
                            line.Service_Type__c,line.Department__c,'Default','Default','Default','Default', line.Revenue_Type__c);
                            lstNonTaxableInvoiceLines.add(objInvoiceLine);
                        }
                    }
                }
            }
            
            String invType = '';
            if(objServiceRequest.HexaBPM__SR_Price_Items1__r.size() > 0){
                invType = objServiceRequest.HexaBPM__SR_Price_Items1__r[0].Invoice_Type1__c;
            }
            invObj = new InputParameters_Class(objServiceRequest.Name, objServiceRequest.Id, objServiceRequest.HexaBPM__Customer__r.Oracle_Party_Id__c,'Access' ,objServiceRequest.RecordType.Name,
            invType,InvoiceDate,objServiceRequest.HexaBPM__Customer__r.Oracle_Site_Id__c,'Invoice','Immediate','AED','WALLET',null);

        }
        system.debug('lstRefundTaxableLines==>'+lstRefundTaxableLines.size()+' == '+lstRefundTaxableLines);
        system.debug('lstTaxableInvoiceLines==>'+lstTaxableInvoiceLines.size()+' == '+lstTaxableInvoiceLines);
        system.debug('lstRefundNonTaxableLines==>'+lstRefundNonTaxableLines.size()+' == '+lstRefundNonTaxableLines);
        system.debug('lstNonTaxableInvoiceLines==>'+lstNonTaxableInvoiceLines.size()+' == '+lstNonTaxableInvoiceLines);
        
        if(lstRefundTaxableLines.size()>0 && lstTaxableInvoiceLines.size()>0){
            for(LINE_REC_TYPE_CLASS RefundInvoice:lstRefundTaxableLines){
                for(LINE_REC_TYPE_CLASS MainInvoice:lstTaxableInvoiceLines){
                    if((Decimal.valueof(RefundInvoice.X5_AMOUNT)*-1) <= Decimal.valueof(MainInvoice.X5_AMOUNT)){ 
                        MainInvoice.X5_AMOUNT = String.valueOf( Decimal.valueof(MainInvoice.X5_AMOUNT) + Decimal.valueof(RefundInvoice.X5_AMOUNT) );
                        MainInvoice.X4_TAX_CODE = '5%';
                        break;
                    }
                }
            }
        }
        if(lstRefundNonTaxableLines.size()>0 && lstNonTaxableInvoiceLines.size()>0){
            for(LINE_REC_TYPE_CLASS RefundInvoice:lstRefundNonTaxableLines){
                for(LINE_REC_TYPE_CLASS MainInvoice:lstNonTaxableInvoiceLines){
                    if((Decimal.valueof(RefundInvoice.X5_AMOUNT) * -1) <= Decimal.valueof(MainInvoice.X5_AMOUNT)){
                        MainInvoice.X5_AMOUNT = String.valueof(Decimal.valueof(MainInvoice.X5_AMOUNT) + Decimal.valueof(RefundInvoice.X5_AMOUNT));
                        MainInvoice.X4_TAX_CODE = 'Exempt 0%';
                        break;
                    }
                }
            }
        }
        
        // create invoice line item list
        if( invoiceId <> null) {
            // create taxble line item
            for (LINE_REC_TYPE_CLASS objLINE_REC_TYPE_CLASS : lstTaxableInvoiceLines) {
                listInvoiceLineItem.add(mapInvoiceLineItem(objLINE_REC_TYPE_CLASS,true, invoiceId, mapTaxbleSRPwithILT.get(objLINE_REC_TYPE_CLASS.X6_ITEM_SFID) ));
            }
            // create non-taxble line item            
            for (LINE_REC_TYPE_CLASS objLINE_REC_TYPE_CLASS : lstNonTaxableInvoiceLines) {
                listInvoiceLineItem.add(mapInvoiceLineItem(objLINE_REC_TYPE_CLASS,false, invoiceId, mapNonTaxbleSRPwithILT.get(objLINE_REC_TYPE_CLASS.X6_ITEM_SFID)  ));
            }
        }
        
        if(lstTaxableInvoiceLines.size()>0)
            lstInvoiceLines.addAll(lstTaxableInvoiceLines);
        if(lstNonTaxableInvoiceLines.size()>0)
            lstInvoiceLines.addAll(lstNonTaxableInvoiceLines);
        integer i = 0;
        
        List<LINE_REC_TYPE_CLASS> lineItemList = new List<LINE_REC_TYPE_CLASS>();
        if(lstInvoiceLines.size()>0){
            for(LINE_REC_TYPE_CLASS line:lstInvoiceLines){
                lineItemList.add(new LINE_REC_TYPE_CLASS(line.X9_INV_DISCOUNT_TAX_AMT, line.X8_INV_DISCOUNT_AMT, line.X7_ITEM_REF, line.X6_ITEM_SFID, line.X5_AMOUNT,line.X4_TAX_CODE, line.X3_ITEM_DESC,line.X2_LINE_DESCRIPTION,
                line.Y1_ACCOUNTS,line.Y2_COST_CENTRE,line.Y3_PROJECT,'Default',line.Y5_PROGRAM,'Default', line.Y7_REVENUE_TYPE));
            }
        }

        P_LINE_TBL_CLASS lineTblClass = new P_LINE_TBL_CLASS();
        lineTblClass.LINE_REC_TYPE.addAll(lineItemList);
        invObj.P_LINE_TBL = lineTblClass;
        CreateInvoice_Class obj = new CreateInvoice_Class();
        obj.InputParameters = invObj;
        CreateInvoice_Wrapper wrapperObj = new CreateInvoice_Wrapper();
        wrapperObj.CreateInvoice = obj;
        String s = JSON.serialize(wrapperObj);
        reqPara objClass = new reqPara();
        objClass.P_SR_Header = s;
        //invObj = constructFinalWrapper(invObj,lineItemList);
        system.debug(objClass);
        return JSON.serialize(objClass);
    }*/
    
    public static CreateInvoice_Class constructFinalWrapper(InputParameters_Class ipobj, List<LINE_REC_TYPE_CLASS> invlineobjs){ P_LINE_TBL_CLASS lineTblClass = new P_LINE_TBL_CLASS(); lineTblClass.LINE_REC_TYPE.addAll(invlineobjs);ipobj.P_LINE_TBL = lineTblClass;CreateInvoice_Class obj = new CreateInvoice_Class();obj.InputParameters = ipobj; return obj; }
    
    
    public static Invoice_Line_Item__c mapInvoiceLineItem (LINE_REC_TYPE_CLASS line, Boolean isTaxable, Id invoiceId, Id invoicelineId) {
        Invoice_Line_Item__c objInvoiceLineItem = new Invoice_Line_Item__c();
        if(invoicelineId <> null) {objInvoiceLineItem.id = invoicelineId;}
        objInvoiceLineItem.RecordTypeId = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByName().get('Invoice Line Item').getRecordTypeId();
        objInvoiceLineItem.Invoice__c = invoiceId; objInvoiceLineItem.Amount__c = line.X5_AMOUNT <> null ? Decimal.valueof(line.X5_AMOUNT):0; 
        objInvoiceLineItem.Taxable_Discount_Amount__c = line.X9_INV_DISCOUNT_TAX_AMT <> null ? Decimal.valueof(line.X9_INV_DISCOUNT_TAX_AMT) : 0;
        objInvoiceLineItem.Discount_Amount__c = line.X8_INV_DISCOUNT_AMT <> null ? Decimal.valueof(line.X8_INV_DISCOUNT_AMT) : 0; 
        objInvoiceLineItem.Item_Reference__c = line.X7_ITEM_REF;objInvoiceLineItem.Item_Description__c = line.X3_ITEM_DESC;objInvoiceLineItem.Line_Description__c = line.X2_LINE_DESCRIPTION;
        objInvoiceLineItem.SR_Price_Item__c  = line.X6_ITEM_SFID;objInvoiceLineItem.Tax__c = line.X4_TAX_CODE; objInvoiceLineItem.Is_Taxable__c = isTaxable;
        if(pricingItemMap.containskey(line.X6_ITEM_SFID)){objInvoiceLineItem.Department__c = pricingItemMap.get(line.X6_ITEM_SFID).Department__c;
                                                          objInvoiceLineItem.Service_Type__c = pricingItemMap.get(line.X6_ITEM_SFID).Service_Type__c;
                                                          objInvoiceLineItem.Service_Class__c = pricingItemMap.get(line.X6_ITEM_SFID).Service_Class__c;
                                                          objInvoiceLineItem.Revenue_Type__c = pricingItemMap.get(line.X6_ITEM_SFID).Revenue_Type__c;
        }
        return objInvoiceLineItem;
    }
    
    
    /*
        Method Name     :   PushAdjToOracle_Future
        Description     :   Http Callout to Informatica Cloud to create Adjust in Oracle
        Input Params    :   Invoice line item Record Id
    */
    //@Future(callout=true)
    public static void PushAdjToOracle_Future(string invoiceLineItemId) {    PushAdjToOracle(invoiceLineItemId);        }
    
    public static AdjustmentResponseWrapper PushAdjToOracle(string invoiceLineItemId){
        AdjustmentResponseWrapper responseWrapper = new AdjustmentResponseWrapper();
        map<string, string> mapAdjustmentTaxCodes = new map<string, string>();

        if(string.isNotBlank(invoiceLineItemId) && invoiceLineItemId !=null){
            try{
                Boolean isIax = false;
                List<Invoice_Line_Item__c> listInvoiceLineItem = new List<Invoice_Line_Item__c>();
                listInvoiceLineItem = [SELECT ID, Activity_Name__c, Type__c, Amount__c, Invoice__c,Invoice__r.Payment_Currency__c,Invoice__r.Invoice_Balance__c,Invoice__r.Conversion_Rate__c,
                                        Invoice__r.Converted_Invoice_Balance__c,Invoice__r.Oracle_Invoice_Id__c,Invoice_Line_Item__r.Line_No__c,Invoice_Line_Item__c,  Date_Of_Adjustment__c, Invoice__r.Entity__r.Oracle_Site_Id__c, 
                                        Line_No__c, Oracle_Response_Message__c, Status__c, Oracle_Adjustment_No__c,Tax__c,Tax_Amount__c, Authority__c
                                        FROM Invoice_Line_Item__c WHERE RecordType.Name = 'Adjustment' AND  Id =: invoiceLineItemId];
                
                if(listInvoiceLineItem <> null && listInvoiceLineItem.size() > 0){
                    Invoice__c objInvoice = new Invoice__c();
                    if( listInvoiceLineItem[0].Type__c == 'Invoice' && listInvoiceLineItem[0].Activity_Name__c != null && listInvoiceLineItem[0].Activity_Name__c.contains('Invoice Cancellation') && !listInvoiceLineItem[0].Activity_Name__c.contains('Tax') ){	objInvoice.Invoice_Balance__c = 0;objInvoice.Converted_Invoice_Balance__c = 0; } 
                    else {objInvoice.Invoice_Balance__c = listInvoiceLineItem[0].Invoice__r.Invoice_Balance__c + listInvoiceLineItem[0].Amount__c;
                        if(listInvoiceLineItem[0].Invoice__r.Conversion_Rate__c > 0 && listInvoiceLineItem[0].Invoice__r.Payment_Currency__c <> 'AED') {objInvoice.Converted_Invoice_Balance__c = objInvoice.Invoice_Balance__c *  listInvoiceLineItem[0].Invoice__r.Conversion_Rate__c ;} 
                        else {objInvoice.Converted_Invoice_Balance__c = objInvoice.Invoice_Balance__c ;}
                    }
                    
                    listInvoiceLineItem[0].Status__c = 'Invoiced';listInvoiceLineItem[0].Journal_Created__c = true;
                    if(isIax && listInvoiceLineItem[0].Tax_Amount__c != 0 && listInvoiceLineItem[0].Tax_Amount__c != null && listInvoiceLineItem[0].Activity_Name__c == 'Invoice Cancellation'){objInvoice.Invoice_Balance__c = objInvoice.Invoice_Balance__c + listInvoiceLineItem[0].Tax_Amount__c;
                        if(listInvoiceLineItem[0].Invoice__r.Conversion_Rate__c > 0 && listInvoiceLineItem[0].Invoice__r.Payment_Currency__c <> 'AED') {objInvoice.Converted_Invoice_Balance__c = objInvoice.Invoice_Balance__c *  listInvoiceLineItem[0].Invoice__r.Conversion_Rate__c ; } 
                        else {objInvoice.Converted_Invoice_Balance__c = objInvoice.Invoice_Balance__c ;}
                    }
                            
                            
                            //---------------------New Adjustment code 31/08/2020-------------------------------
                    List<Invoice_Line_Item__c> linesToInsert = new List<Invoice_Line_Item__c>(); Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get('Invoice_Line_Item__c').getDescribe().fields.getMap();
                    system.debug('--->'+ mfields.keyset());
                    List<String> fieldList = new List<String>(); fieldList.addAll(mfields.keyset());
                    if(listInvoiceLineItem[0].Activity_Name__c == 'Invoice Cancellation'){ String invId = listInvoiceLineItem[0].Invoice__c; 
                        String qString = 'SELECT '+String.join(fieldList,',')+ ' FROM Invoice_Line_Item__c WHERE Invoice__c =\''+invId+'\' AND Recordtype.DeveloperName = \'Invoice_Line_Item\''; 
                        system.debug('======>>'+ qString);
                        List<Invoice_Line_Item__c> invoiceLines = Database.query(qString);//[select id from Invoice_Line_Item__c WHERE Invoice__c =: listInvoiceLineItem[0].Invoice__c AND Recordtype.DeveloperName = 'Invoice_Line_Item'] ; 
                        for(Invoice_Line_Item__c ili : invoiceLines){
                            Invoice_Line_Item__c newlineItem = ili.clone(false);newLineItem.Is_From_Adjustment__c = true;newLineItem.GL_Date__c = Date.today();newLineItem.Amount__c = newLineItem.Amount__c * -1;
                            if(newLineItem.Tax_Amount__c != null){newLineItem.Tax_Amount__c = newLineItem.Tax_Amount__c * -1;}
                            linesToInsert.add(newlineItem);
                        }
                        List<Id> journalHeaderId = new List<Id>(); Id jhId = [Select Id from Journal_Header__c where Invoice__c =: listInvoiceLineItem[0].Invoice__c AND Transaction_Type__c = 'Sales Invoices' LIMIT 1].Id;
                        journalHeaderId.add(jhId); System.debug('journalHeaderId===='+journalHeaderId); BM_JournalEntryEngine.journalEntryCreationForHeaderReversal(journalHeaderId, 'Invoice Cancellation');
                    } else if(listInvoiceLineItem[0].Activity_Name__c == 'Fee Waiver'){ String lineId = listInvoiceLineItem[0].Invoice_Line_Item__c;
                        String qString = 'SELECT '+String.join(fieldList,',')+ ' FROM Invoice_Line_Item__c WHERE Id = \''+lineId+'\' AND Recordtype.DeveloperName = \'Invoice_Line_Item\''; 
                        List<Invoice_Line_Item__c> invoiceLines = Database.query(qString); Invoice_Line_Item__c newlineItem = invoiceLines[0].clone(false);
                        newlineItem.Amount__c = listInvoiceLineItem[0].Amount__c;newLineItem.Tax_Amount__c = 0;newLineItem.GL_Date__c = Date.today();newlineItem.Is_Discount__c = true;newlineItem.Revenue_Type__c = 'Discount-' + invoiceLines[0].Revenue_Type__c;newlineItem.Quantity__c = 1;newlineItem.Invoice_Line_Item__c = listInvoiceLineItem[0].Invoice_Line_Item__c;newlineItem.Discount_Amount__c = 0; newlineItem.Line_Description__c = 'Created From Adjustment';//objInvoice_Line_Item.Discount_Description__c;
                        
                        linesToInsert.add(newlineItem);
                    }
                    else if(listInvoiceLineItem[0].Activity_Name__c != 'Fee Waiver' && listInvoiceLineItem[0].Activity_Name__c != 'Invoice Cancellation'){ List<Id> liId = new List<Id>();liId.add(listInvoiceLineItem[0].Id);BM_JournalEntryEngine.invoiceAdjustmentCreationJournal(liId);
                    }
                    List<Id> LiId = new List<Id>();
                    if(linesToInsert.size() > 0){InvoiceLineItemTriggerHandler.isCreateDiscount = false; insert linesToInsert; system.debug('linesToInsert--->'+linesToInsert);
                        for(Invoice_Line_Item__c li: linesToInsert){system.debug('li--->'+li);
                            if(li.Revenue_Type__c.contains('Discount-')){LiId.add(li.Id);}
                        }
                        system.debug('LiId--->'+LiId);
                        if(LiId.size()>0){BM_JournalEntryEngine.discountAdjustmentCreationJournal(LiId);}
                        InvoiceLineItemTriggerHandler.isCreateDiscount = true;
                    }
                    
                    objInvoice.id = listInvoiceLineItem[0].Invoice__c;listInvoiceLineItem[0].Oracle_Response_Message__c = responseWrapper.P_OP_ERROR_MSG;update objInvoice;
                    system.debug('--->'+listInvoiceLineItem);
                    
                    update listInvoiceLineItem[0]; 
                    
                    return responseWrapper;
                }
                
            } catch(Exception ex) { system.debug('--->'+ex.getMessage()); String sMessage = ex.getMessage(); Log__c objLog = new Log__c(); if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} else {objLog.Message__c = sMessage; }  objLog.Line_Number__c = ex.getLineNumber(); objLog.Stack_Trace__c =  ex.getStackTraceString(); objLog.Type_Name__c = ex.getTypeName(); objLog.User_Email__c = UserInfo.getUserEmail(); insert objLog; responseWrapper.P_OP_STATUS = 'E'; responseWrapper.P_OP_ERROR_MSG = ex.getMessage(); return responseWrapper; }
        }
        return responseWrapper;
    }
    
    public static map<string, string> getAdjustmentTaxActivities(string authority){
        map<string, string> mapActivities = new map<string,string>();
        for(Revenue_Classification__c objRC : [select Id,Activity_Name__c,Source_System_Name__c from Revenue_Classification__c 
                                                    where Type__c = 'Adjustment Tax' AND Source_System_Name__c =:authority AND Activity_Name__c != null ]){mapActivities.put(objRC.Source_System_Name__c, objRC.Activity_Name__c);
        }
        return mapActivities;
    }

    public static List<String> trimAllValues (List<String> listValues) {
        List<String> listTrimmedValues = new List<String>();
        for(String objVal : listValues) {
            listTrimmedValues.add(objVal.trim());
        }
        return listTrimmedValues;
    }

    /*
        Method Name     :   PushAdjToSourceSystem_Future
        Description     :   Http Callout to Informatica Cloud to push the adjustment invoice line item to the coresponding source system
        Input Params    :   Invoice line item Record Id
    */
    /*@Future(callout=true)
    public static void PushAdjToSourceSystem_Future(string invoiceLineItemId){
        PushAdjToSourceSystem(invoiceLineItemId);        
    }*/
    
    public static void PushAdjToSourceSystem(string invoiceLineItemId){
        if(string.isNotBlank(invoiceLineItemId) && invoiceLineItemId !=null){
            try{
                Boolean isIax = false;
                List<Invoice_Line_Item__c> listInvoiceLineItem = new List<Invoice_Line_Item__c>();
                listInvoiceLineItem = [SELECT ID, Createdby.name, Activity_Name__c, Type__c, Amount__c, Invoice__c,Invoice__r.Payment_Currency__c,Invoice__r.Invoice_Balance__c,Invoice__r.Conversion_Rate__c,
                                        Invoice__r.Converted_Invoice_Balance__c,Invoice__r.Id,Invoice_Line_Item__r.Line_No__c,Invoice_Line_Item__c,  Date_Of_Adjustment__c, Invoice__r.Entity__r.Oracle_Site_Id__c, Invoice__r.Entity__c,
                                        Line_No__c, Oracle_Response_Message__c, Status__c, Oracle_Adjustment_No__c,Tax__c,Tax_Amount__c, Authority__c
                                        FROM Invoice_Line_Item__c WHERE RecordType.Name = 'Adjustment' AND  Id =: invoiceLineItemId];
                
                if(listInvoiceLineItem <> null && listInvoiceLineItem.size() > 0){
                    Invoice_Line_Item__c invRecord = listInvoiceLineItem[0];
                    // get endpoint details                   
                    String oracleSiteId = '';
                    if(invRecord.Invoice__c != null && invRecord.Invoice__r.Entity__c != null && invRecord.Invoice__r.Entity__r.Oracle_Site_Id__c != null ){
                        oracleSiteId = invRecord.Invoice__r.Entity__r.Oracle_Site_Id__c;
                    }
                    List<Operating_Unit__c> listERPEndpointDetails = new List<Operating_Unit__c>();
                    listERPEndpointDetails = [SELECT ID,Invoice_Adjustment_Source_Endpoint__c,Oracle_Site_Id__c FROM Operating_Unit__c WHERE Oracle_Site_Id__c =: oracleSiteId];
                    if(listERPEndpointDetails <> null && listERPEndpointDetails.size() > 0 ){
                        String endpointURL = listERPEndpointDetails[0].Invoice_Adjustment_Source_Endpoint__c;
                        if(endpointURL <> null && string.isNotBlank(endpointURL)){ AdjustmentSourceRequestWrapper objAdjustmentRequestWrapper = new AdjustmentSourceRequestWrapper();objAdjustmentRequestWrapper.P_IN_INVOICECRMID = invRecord.Invoice__r.Id;         objAdjustmentRequestWrapper.P_IN_AMOUNT = invRecord.Amount__c;objAdjustmentRequestWrapper.P_IN_ADJUSTMENTDATE = invRecord.Date_Of_Adjustment__c;objAdjustmentRequestWrapper.P_IN_ACTIVITYNAME = invRecord.Activity_Name__c;objAdjustmentRequestWrapper.P_IN_INVOICELINEITEMID = invRecord.ID;objAdjustmentRequestWrapper.P_IN_ADJUSTMENTCREATEDBY = invRecord.Createdby.name;

                            String sInputValue = JSON.serialize(objAdjustmentRequestWrapper); InvoiceAdjustmentSourceWrapper invAdjustWrap = new InvoiceAdjustmentSourceWrapper();invAdjustWrap.IN_InvoiceAdjustment = sInputValue;string requestBody = JSON.serialize(invAdjustWrap);
                            system.debug('Request Body--->'+requestBody);

                            HTTPResponse objHTTPResponse = new HTTPResponse();objHTTPResponse = HTTPRestUtil.callWebservice(endpointURL, 'POST', requestBody);
                            system.debug('Adjustment source system response body-----> '+objHTTPResponse.getBody());    
                        }
                    }
                }
            }
            catch(Exception ex){String sMessage = ex.getMessage();Log__c objLog = new Log__c(); if(sMessage .length() > 240) {objLog.Message__c = sMessage.subString(0,240);} else {objLog.Message__c = sMessage;} objLog.Line_Number__c = ex.getLineNumber();objLog.Stack_Trace__c =  ex.getStackTraceString();objLog.Type_Name__c = ex.getTypeName(); objLog.User_Email__c = UserInfo.getUserEmail();insert objLog; }
        }
    }


    //------------------------------------------ Wrapper Classes -------------------------------------------------------------
    public class AdjustmentSourceRequestWrapper{
        public String P_IN_INVOICECRMID;
        public Decimal P_IN_AMOUNT;
        public Date P_IN_ADJUSTMENTDATE;
        public String P_IN_ACTIVITYNAME;   
        public String P_IN_INVOICELINEITEMID;  
        public String P_IN_ADJUSTMENTCREATEDBY;   
    }
    public class InvoiceAdjustmentSourceWrapper{
        public String IN_InvoiceAdjustment;
    }

    public class AdjustmentRequestWrapper {
        public string P_IN_INVOICE_NO;
        public string P_IN_ACTIVITY_NAME;
        public string P_IN_TYPE;
        public string P_IN_ADJ_AMOUNT;
        public string P_IN_LINE_NO;
        public string P_IN_DATE;
        public string P_IN_SFID;
        public string P_IN_ORG_ID;
    }
    
    public class AdjustmentResponseWrapper {
        public string P_OP_ADJUSTMENT_NO;
        public string P_OP_STATUS;
        public string P_OP_ERROR_MSG;
    }
    public class reqPara {
        public String P_SR_Header;
    }

    public class CreateInvoice_Wrapper{
        public CreateInvoice_Class CreateInvoice;
    }
    
    public Class CreateInvoice_Class{
        public InputParameters_Class InputParameters;    
    }
    
    public class InputParameters_Class{
        public string P_INV_SR_REF;
        public string P_SFID;
        public string P_ORA_CUST_ID;
        public string P_INV_BATCH_SOURCE; //New Field to pass source system name
        public string P_INV_DESC;
        public string P_INV_TYPE;
        public string P_INV_DATE;
        public string P_ORG_ID;
        public string P_INV_CLASS;
        public string P_PAYMENT_TERM;
        public string P_CURRENCY;
        public string P_INV_STATUS;
        public string P_RECEIPT_NO;
        public P_LINE_TBL_CLASS P_LINE_TBL;

        public InputParameters_Class(String INV_SR_REF, String SFID, String ORA_CUST_ID, String sourceSys, String INV_DESC, String INV_TYPE, String INV_DATE, String ORG_ID, String INV_CLASS, String PAYMENT_TERM, String INVCURRENCY, String INV_STATUS, String RECEIPT_NO){
            P_INV_SR_REF = INV_SR_REF;
            P_SFID = SFID;
            P_ORA_CUST_ID = ORA_CUST_ID;
            P_INV_BATCH_SOURCE = sourceSys;
            P_INV_DESC = INV_DESC;
            P_INV_TYPE = INV_TYPE;
            P_INV_DATE = INV_DATE;
            P_ORG_ID = ORG_ID;
            P_INV_CLASS = INV_CLASS;
            P_PAYMENT_TERM = PAYMENT_TERM;
            P_CURRENCY = INVCURRENCY;
            P_INV_STATUS = INV_STATUS;
            P_RECEIPT_NO = RECEIPT_NO;
        }
    }
    
    public class P_LINE_TBL_CLASS{
        public List<LINE_REC_TYPE_CLASS> LINE_REC_TYPE;
        public P_LINE_TBL_CLASS(){
            LINE_REC_TYPE = new List<LINE_REC_TYPE_CLASS>();
        }
    }
    
    public class LINE_REC_TYPE_CLASS{
        public string X9_INV_DISCOUNT_TAX_AMT;
        public string X8_INV_DISCOUNT_AMT;
        public string X7_ITEM_REF;
        public string X6_ITEM_SFID;
        public string X5_AMOUNT;
        //public string X4_TAX_AMOUNT;
        public string X4_TAX_CODE;
        public string X3_ITEM_DESC;
        public string X2_LINE_DESCRIPTION;
        public string Y1_ACCOUNTS; // (Revenue Type in SF)
        public string Y2_COST_CENTRE; // (BRC  Segment)
        public string Y3_PROJECT; // (Courses for Academy)
        public string Y4_INTERCOMPANY; // (Default)
        public string Y5_PROGRAM; //(Schools for Academy)
        public string Y6_FUTURE2; // (Default)
        public string Y7_REVENUE_TYPE; // (Revenue Type in SF)
        public LINE_REC_TYPE_CLASS(String INV_DISCOUNT_TAX_AMT, String INV_DISCOUNT_AMT, String ITEM_REF, String ITEM_SFID, String AMOUNT, String TAX_CODE, String ITEM_DESC, String LINE_DESC,
                                    String revenueType, String BRCSegment, String courses, String intCompany, String schools, String future2, String revType){
            X9_INV_DISCOUNT_TAX_AMT = null;//(INV_DISCOUNT_TAX_AMT != '0.0' && INV_DISCOUNT_TAX_AMT != '0.00' ? INV_DISCOUNT_TAX_AMT : null);
            X8_INV_DISCOUNT_AMT = null; //(INV_DISCOUNT_AMT != '0.0' && INV_DISCOUNT_AMT != '0.00' ? INV_DISCOUNT_AMT : null);
            X7_ITEM_REF = ITEM_REF;
            X6_ITEM_SFID = ITEM_SFID;
            X5_AMOUNT = AMOUNT;
            X4_TAX_CODE = TAX_CODE;//X4_TAX_AMOUNT = TAX_AMOUNT;
            X3_ITEM_DESC = ITEM_DESC;//'Registration-Entities';//ITEM_DESC;
            X2_LINE_DESCRIPTION = LINE_DESC;
            Y1_ACCOUNTS = revenueType;
            Y2_COST_CENTRE = BRCSegment;
            Y3_PROJECT = courses;
            Y4_INTERCOMPANY = intCompany;
            Y5_PROGRAM = schools;
            Y6_FUTURE2 = future2;
            Y7_REVENUE_TYPE = revType;
        }
    }

    public class OutputParameters{
       /* public string X_SFID;
        public string X_INV_NUM;
        public string X_CM_NUM;
        public string X_CUST_ID;
        public string X_ORG_ID;
        public string X_INV_AMOUNT;
        public string X_TAX_AMOUNT;
        public string X_DISCOUNT_AMOUNT;
        public string X_GL_DATE;
        public string X_LINE_DETAILS;
        public string X_RETURN_STS;
        public string X_RETURN_MSG; */
        public string P_OP_CM_NUM;
        public string P_OP_INV_NUM;
        public string P_OP_RETURN_STS;
        public string P_OP_RETURN_MSG;
        public string P_OP_ORG_ID;
        
        public string P_OP_CONVERTED_AMT;
        public string P_OP_CONVERTED_TAXAMT;
        public string P_OP_CONVERTED_DISCOUNT;

        
        public string P_OP_GL_DATE;
        public string P_OP_SFID;
        public string P_OP_LINE_DETAILS;
        public string P_OP_CUST_ID;
        public string P_OP_APPL_RECEIPT_NO;
        public string P_OP_AMT_APPLIED;
        public string P_OP_AMT_UNAPPLIED;
        public string P_OP_AMT_INV_BAL;
        public List<LINE_DETAILS> P_OP_LINE_ITEM_DETAILS;
        
        
        public string P_OP_CONV_DISCOUNT_TAX_AMOUNT;
        public string P_OP_INV_AMOUNT;
        public string P_OP_TAX_AMOUNT;
        public string P_OP_DISCOUNT_AMOUNT;
        public string P_OP_DISCOUNT_TAX_AMOUNT;
        public string P_OP_CONV_AMT_APPLIED;
        public string P_OP_CONV_AMT_UNAPPLIED;
        public string P_OP_CONV_AMT_INV_BAL;
    }

    public class LINE_DETAILS {
        public String X6_ITEM_REF;
        public String X3_TAX_AMOUNT;
        public String X2_ITEM_DESC;
        public String X9_LINE_NO;
        public String X5_ITEM_SFID;
        public String X8_INV_DISCOUNT_TAX_AMT;
        public String X7_INV_DISCOUNT_AMT;
        public String X4_AMOUNT;
    }

    public class LineDetails{
        public list<LineDetailsWrapper> P_LINE_TBL;
        public LineDetails(){P_LINE_TBL = new list<LineDetailsWrapper>(); }
    }

    public class LineDetailsWrapper{
        public string Line_No;
        public string X_INV_DISCOUNT_TAX_AMT;
        public string X_INV_DISCOUNT_AMT;
        public string X_ITEM_REF;
        public string X_ITEM_SFID;
        public string X_AMOUNT;
        public string X_TAX_AMOUNT;
    }
}