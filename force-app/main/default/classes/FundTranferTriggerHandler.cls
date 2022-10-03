/**
 * @File Name          : FundTranferTriggerHandler.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 3/24/2020, 1:51:09 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/23/2020   Jayanta Karmakar     Initial Version
**/
public class FundTranferTriggerHandler {
    public static Boolean runUpdate = true;
    
    public static void handleAU(List<Fund_Transfer__c> newList,map<Id,Fund_Transfer__c> TriggerOldMap){
        Set<Fund_Transfer__c> lstFtwithGLError = new Set<Fund_Transfer__c>();
        if(runUpdate)
        pushToOracle(newList);
        
        for(Fund_Transfer__c ftRec : newList){
            if(TriggerOldMap.get(ftRec.Id).GL_Date__c != ftRec.GL_Date__c){lstFtwithGLError.add(ftRec);}
        }
        if(lstFtwithGLError.size()>0){updateCloseDateErrorJVs(lstFtwithGLError);}
            
    }


    public static void pushToOracle(List<Fund_Transfer__c> newList){
        List<String> fundTransferIds = new List<String>();
        for(Fund_Transfer__c eachRecord : newList){
            if(eachRecord.Status__c == 'Approved' && !eachRecord.Journal_Created__c){fundTransferIds.add(eachRecord.id);    }
        }

        BalanceTransferUtil.updateReceiptAndCreateJournalEntriesFuture(fundTransferIds);
        //Added code for JE Creation
        //if(fundTransferIds.size()>0){BM_JournalEntryEngine.fundTransferJournalEntries(fundTransferIds);}
            
    }
    
    public static void updateCloseDateErrorJVs(Set<Fund_Transfer__c> invIDs){
        List<Journal_Header__c> jvsToUpdate = new List<Journal_Header__c>();
        Map<Fund_Transfer__c,list<Journal_Header__c>> jvMap = new Map<Fund_Transfer__c,list<Journal_Header__c>>();
        for(Fund_Transfer__c inv : invIDs){
            List<Journal_Header__c> jvLst = [Select Id, GL_Date__c,Oracle_Status__c,Error_Message__c from Journal_Header__c where Fund_Transfer__c=:inv.Id AND Oracle_Status__c = 'Error' 
                                         AND Error_Message__c LIKE 'GL Period is not open%'];
            System.debug('jvLst with close GL Date error: '+jvLst);
            System.debug('inv: '+inv);
            jvMap.put(inv,jvLst);
        }
        for(Fund_Transfer__c inv : jvMap.keyset()){
            for(Journal_Header__c jh : jvMap.get(inv)){
                jh.GL_Date__c = inv.GL_Date__c;jh.Oracle_Status__c = 'Draft';jh.Error_Message__c = '';
                jvsToUpdate.add(jh);
            }
        }
        if(jvsToUpdate.size()>0){update jvsToUpdate;}
        
    }
}