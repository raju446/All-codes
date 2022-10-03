/******
    Name           : RelatedInvoiceReceiptTriggerHelper
    Author         : PwC
    Description    : Application trigger helper to create journal entries of transactions.

******/


public class RelatedInvoiceReceiptTriggerHelper {
    
    //this method we are using to update amount on application and create journal records.
    public static void updateAmountANDCreateJournalEntries(Map < Id, Related_Invoice_Receipt__c > applicationMap) {
        try{
            Map < Id, Invoice__c > invoiceMap = new Map < Id, Invoice__c > ();
            Map < Id, Receipt__c > receiptMap = new Map < Id, Receipt__c > ();
            Map < Id, Decimal > invoiceBalanceMap = new Map < Id, Decimal > ();
            Map < Id, Decimal > receiptBalanceMap = new Map < Id, Decimal > ();
            set < Id > invIds = new set < Id > ();
            set < Id > recIds = new set < Id > ();
            for (String key: applicationMap.keySet()) {
                invIds.add(applicationMap.get(key).Invoice__c);
                recIds.add(applicationMap.get(key).Receipt__c);
            }
    
            invoiceMap = new Map < Id, Invoice__c > ([SELECT Id, Invoice_Balance__c, Payment_Currency__c, Conversion_Rate__c FROM Invoice__c WHERE Id IN: invIds AND Journal_Created__c = true AND Invoice_Balance__c > 0]);
            receiptMap = new Map < Id, Receipt__c > ([SELECT Id, Remaning_Amount__c, Payment_Currency__c, Conversion_Rate__c FROM Receipt__c WHERE Id IN: recIds AND Journal_Created__c = true AND Remaning_Amount__c > 0]);
            List < Related_Invoice_Receipt__c > appList = new List < Related_Invoice_Receipt__c > ();
            List < String > appIds = new List < String > ();
            for (String appId: applicationMap.keySet()) {
                Related_Invoice_Receipt__c appObj = applicationMap.get(appId).clone(); //applicationMap.get(appId);
                appObj.Id = appId;
                Invoice__c invObj = invoiceMap.get(appObj.Invoice__c);
                Receipt__c recObj = receiptMap.get(appObj.Receipt__c);
                if (invoiceMap.containsKey(appObj.Invoice__c) && receiptMap.containsKey(appObj.Receipt__c)) {
                    /*if ((appObj.Amount_Applied__c == null || appObj.Amount_Applied__c == 0)) {
                        if (invObj.Invoice_Balance__c <= recObj.Remaning_Amount__c) {
                            appObj.Oracle_Applied_Amount__c = invObj.Invoice_Balance__c;
                            appObj.Amount_Applied__c = invObj.Invoice_Balance__c;
                            appObj.Oracle_Converted_Applied_Amount__c = invObj.Payment_Currency__c == 'USD' ? invObj.Invoice_Balance__c * invObj.Conversion_Rate__c : invObj.Invoice_Balance__c;
                            invoiceBalanceMap.put(invObj.Id, 0);
                        } else {
                            appObj.Oracle_Applied_Amount__c = recObj.Remaning_Amount__c;
                            appObj.Amount_Applied__c = recObj.Remaning_Amount__c;
                            appObj.Oracle_Converted_Applied_Amount__c = invObj.Payment_Currency__c == 'USD' ? recObj.Remaning_Amount__c * invObj.Conversion_Rate__c : recObj.Remaning_Amount__c;
                            invoiceMap.get(invObj.Id).Invoice_Balance__c = invObj.Invoice_Balance__c - recObj.Remaning_Amount__c;
                            invoiceBalanceMap.put(invObj.Id, invObj.Invoice_Balance__c - recObj.Remaning_Amount__c);
                        }
                    } else */
                    if (appObj.Amount_Applied__c > 0) {
                        appObj.Oracle_Applied_Amount__c = appObj.Amount_Applied__c;
                        appObj.Oracle_Converted_Applied_Amount__c = invObj.Payment_Currency__c == 'USD' ? appObj.Amount_Applied__c * invObj.Conversion_Rate__c : appObj.Amount_Applied__c;
                        invoiceMap.get(invObj.Id).Invoice_Balance__c = invObj.Invoice_Balance__c - appObj.Amount_Applied__c;
                        invoiceBalanceMap.put(invObj.Id, (invoiceMap.get(invObj.Id)).Invoice_Balance__c - appObj.Amount_Applied__c);
                    }
                    appObj.Journal_Created__c = true;
                    appObj.Applied__c = true;
                    appList.add(appObj);
                    appIds.add(appObj.Id);
                }
            }
            List < Invoice__c > invObjList = new List < Invoice__c > ();
            for (String key: invoiceBalanceMap.keyset()) {
                if (invoiceBalanceMap.get(key) > 0 && invoiceMap.get(key).Invoice_Balance__c != invoiceBalanceMap.get(key)) {
                    Invoice__c invObj = invoiceMap.get(key);
                    if (invObj.Invoice_Balance__c > 0) {
                        invObj.Converted_Invoice_Balance__c = invObj.Payment_Currency__c == 'USD' ? invObj.Invoice_Balance__c * invObj.Conversion_Rate__c : invObj.Invoice_Balance__c;
                    } else {
                        invObj.Converted_Invoice_Balance__c = 0;
                    }
                    invObjList.add(invObj);
                }
            }
            if (!invObjList.isEmpty()) {
                UPDATE invObjList;
            }
            if (!appList.isEmpty()) {
                UPDATE appList;
                BM_JournalEntryEngine.receiptApplicationJournalLines(appIds);
            }
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
        
    }

    public static void Execute_AU(list < Related_Invoice_Receipt__c > TriggerNew, map < Id, Related_Invoice_Receipt__c > TriggerOldMap) {
        Set < Related_Invoice_Receipt__c > lstAppwithGLUpdate = new Set < Related_Invoice_Receipt__c > ();
        for (Related_Invoice_Receipt__c appRec: TriggerNew) {
            if (TriggerOldMap.get(appRec.Id).GL_Date__c != appRec.GL_Date__c) {
                lstAppwithGLUpdate.add(appRec);
            }
        }
        if (lstAppwithGLUpdate.size() > 0) {
            updateCloseDateErrorJVs(lstAppwithGLUpdate);
        }

    }

    //This method we are using to update the GL date on JVs once the application GL date changed.
    public static void updateCloseDateErrorJVs(Set < Related_Invoice_Receipt__c > appIds) {
        List < Journal_Header__c > jvsToUpdate = new List < Journal_Header__c > ();

        Map < Id, list < Journal_Header__c >> jvMap = new Map < Id, list < Journal_Header__c >> ();
        Map < Id, Related_Invoice_Receipt__c > applicationMap = new Map < Id, Related_Invoice_Receipt__c > ();
        for (Related_Invoice_Receipt__c appObj: appIds) {
            applicationMap.put(appObj.Id, appObj);
        }
        for (Journal_Header__c jhObj: [Select Id, GL_Date__c, Related_Invoice_Receipt__c, Oracle_Status__c, Error_Message__c from Journal_Header__c where Related_Invoice_Receipt__c IN: applicationMap.keySet() AND Oracle_Status__c = 'Error'
                AND Error_Message__c LIKE 'GL Period is not open%'
            ]) {
            list < Journal_Header__c > tempLst = jvMap.get(jhObj.Related_Invoice_Receipt__c);
            if (tempLst.isEmpty()) {
                tempLst = new List < Journal_Header__c > ();
            }
            tempLst.add(jhObj);
            jvMap.put(jhObj.Related_Invoice_Receipt__c, tempLst);
        }

        /*for(Related_Invoice_Receipt__c inv : appIds){
            List<Journal_Header__c> jvLst = [Select Id, GL_Date__c,Oracle_Status__c,Error_Message__c from Journal_Header__c where Related_Invoice_Receipt__c=:inv.Id AND Oracle_Status__c = 'Error' 
                                         AND Error_Message__c LIKE 'GL Period is not open%'];
            System.debug('jvLst with close GL Date error: '+jvLst);
            System.debug('inv: '+inv);
            
        }*/
        for (Id appId: jvMap.keyset()) {
            Related_Invoice_Receipt__c appObj = applicationMap.get(appId);
            for (Journal_Header__c jh: jvMap.get(appId)) {
                jh.GL_Date__c = appObj.GL_Date__c;
                jh.Oracle_Status__c = 'Draft';
                jh.Error_Message__c = '';
                jvsToUpdate.add(jh);
            }
        }
        if (jvsToUpdate.size() > 0) {
            update jvsToUpdate;
        }

    }

}