/**
 * @File Name          : RefundTriggerHandler.cls
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 4/7/2020, 2:15:00 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/23/2020   Jayanta Karmakar     Initial Version
**/
public class RefundTriggerHandler {
    
    public static void handleBI(List<Refund__c> newList){
        populateDocumentMaster(newList, null);
    }
    
    public static void handleBU(List<Refund__c> newList, map<Id,Refund__c> mapOldRefunds ){
        populateVersionNumber(newList,mapOldRefunds);
        populateDocumentMaster(newList, mapOldRefunds);
    }
    
    public static void handleAI(List<Refund__c> newList){
        pushToOracle(newList, null);
    }
    
    public static void handleAU(List<Refund__c> newList, map<Id,Refund__c> mapOldRefunds ){
        pushToOracle(newList, mapOldRefunds);
    }

    public static void pushToOracle(List<Refund__c> newList, map<Id,Refund__c> mapOldRefunds){
        List<String> CCrefundIds = new List<String>();
        List<String> BTrefundIds = new List<String>();
        for(Refund__c eachRecord : newList){
            Refund__c oldRecord = mapOldRefunds != null ? mapOldRefunds.get(eachRecord.Id) : new Refund__c();
            if(oldRecord.Status__c != eachRecord.Status__c &&  eachRecord.Status__c == 'Approved' && !eachRecord.Journal_Created__c){
                if(eachRecord.Payment_Method__c == 'Credit Card'){
                    if(eachRecord.Scenario__c == 'Receipt generated but invoice not generated'){ update new Receipt__c(Id = eachRecord.Receipt__c, Refund_Amount__c = eachRecord.Amount__c);
                        } else if(eachRecord.Scenario__c == 'Credit Memo'){ system.debug('---->'+ eachRecord.Credit_Memo__c); Invoice__c cmObj= new Invoice__c();
                            for(Invoice__c inv:[SELECT Id,Invoice_Balance__c FROM Invoice__c WHERE Id =: eachRecord.Credit_Memo__c]){
                            	cmObj = inv;
                            }
                            system.debug('---->'+ cmObj.Invoice_Balance__c);
                            system.debug('---->'+ eachRecord.Amount__c);
                            cmObj.Invoice_Balance__c = cmObj.Invoice_Balance__c + eachRecord.Amount__c; cmObj.Credit_Memo_Refund_Amount__c = eachRecord.Amount__c;
                            if(cmObj!=null && cmObj.Id!=null){ update cmObj; }
                           		
                        }
                    CCrefundIds.add(eachRecord.id); 
                }   
                if(eachRecord.Payment_Method__c == 'Bank Transfer'){ BTrefundIds.add(eachRecord.id); }
                	
            }
        }
		
        if(!system.isFuture() && !system.isBatch()){
            if(BTrefundIds.size()>0){
                //RefundUtil.pushRefundToOracleFuture(BTrefundIds); 
                BM_JournalEntryEngine.refundJournalLines(BTrefundIds);
            }
            	
            if(CCrefundIds.size()>0)
            	BM_JournalEntryEngine.refundJournalLines(CCrefundIds);//in case of CreditCard
        }
        	
    }
    
    public static void populateDocumentMaster(list<Refund__c> lstRefund, map<Id, Refund__c> mapOldInv){
        map<string, HexaBPM__Document_Master__c> mapDocCodes = new map<string,  HexaBPM__Document_Master__c>();
    	        
        set<string> setRefundStatus = new set<string>{
            //Constants.STR_Under_Review,
            //Constants.STR_Approved
        };
	        
        for(Refund__c objRefund : lstRefund){
            Refund__c objOldInv = (mapOldInv != null && mapOldInv.containsKey(objRefund.id)) ? mapOldInv.get(objRefund.Id) : new Refund__c();
            if(objRefund.Document_Master__c == null && string.isNotEmpty(objRefund.Document_Master_Code__c) ){
                mapDocCodes.put(objRefund.Document_Master_Code__c, null);
            }
            if( objRefund.Document_Master__c != null && setRefundStatus.contains(objRefund.Status__c) && objRefund.Status__c != objOldInv.Status__c ){
            	objRefund.Generate_Document__c = true;
            }
        }
        if(!mapDocCodes.isEmpty()){
            for(HexaBPM__Document_Master__c objDM : [select Id,HexaBPM__Code__c from HexaBPM__Document_Master__c where HexaBPM__Code__c IN : mapDocCodes.keySet() ]){
                mapDocCodes.put(objDM.HexaBPM__Code__c, objDM);
            }
        }
        
        for(Refund__c objRefund : lstRefund){
            if(objRefund.Document_Master__c == null &&  mapDocCodes.get(objRefund.Document_Master_Code__c) != null ){
                objRefund.Document_Master__c = mapDocCodes.get(objRefund.Document_Master_Code__c).Id;   objRefund.Generate_Document__c = true;
            }
        }
        }
    	public static Map<Id,Decimal> refundDocVersion;
    
        public static void populateVersionNumber(list<Refund__c> lstRec, map<Id, Refund__c> mapOldRec){
            if(refundDocVersion == null){
                refundDocVersion = new Map<Id,Decimal>();
            }
            for(Refund__c rec: lstRec){
                if(!refundDocVersion.containsKey(rec.Id) && !mapOldRec.get(rec.Id).Generate_Document__c && rec.Generate_Document__c){
                    integer counter = (mapOldRec.get(rec.Id).Document_Version__c != null)?Integer.valueOf(mapOldRec.get(rec.Id).Document_Version__c):0;
                    rec.Document_Version__c = counter + 1;
                    refundDocVersion.put(rec.Id,rec.Document_Version__c );
                }
            }
        }
    
}