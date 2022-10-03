/*
    Author      : Durga Prasad
    Date        : 06-May-2020
    Description : Trigger handler for RA_Receipt_Invoice_TriggerHandler.
    ---------------------------------------------------------------------
*/
public without sharing class RA_Receipt_Invoice_TriggerHandler {
	public static void Execute_BI(list<RA_Receipt_Invoice__c> TriggerNew){
		set<string> setReceiptNumbers = new set<string>();
		map<string,Receipt_Description__c> MapReceiptDescription = new map<string,Receipt_Description__c>();
		for(RA_Receipt_Invoice__c RRI:TriggerNew){
			if(RRI.Receipt_Number__c!=null)
				setReceiptNumbers.add(RRI.Receipt_Number__c);
			if(RRI.Entity_Name__c==null || RRI.Entity_Name__c=='')
				RRI.Entity_Name__c = 'Unidentified';
			if(RRI.Entity_Number__c!=null){
				if(RRI.Entity_Number__c.length() < 9){
					integer DiffLength = 9 - RRI.Entity_Number__c.length();
					string LeadingZeros = '0';
					for(integer i=1;i<DiffLength;i++){
						LeadingZeros = LeadingZeros+'0';
					}
					RRI.Entity_Number__c = LeadingZeros+RRI.Entity_Number__c;
				}
				system.debug('sEntityNumber==>'+RRI.Entity_Number__c);
			}
		}
		if(setReceiptNumbers.size()>0){
			for(Receipt_Description__c RD:[Select Id,Receipt_Number__c,Description__c,Revenue_Classification__c from Receipt_Description__c where Receipt_Number__c IN:setReceiptNumbers]){
				MapReceiptDescription.put(RD.Receipt_Number__c,RD);
			}
		}
		for(RA_Receipt_Invoice__c RRI:TriggerNew){
			if(RRI.Receipt_Number__c!=null && MapReceiptDescription.get(RRI.Receipt_Number__c)!=null){
				RRI.Receipt_Description__c = MapReceiptDescription.get(RRI.Receipt_Number__c).Id;
				RRI.Revenue_Classification__c = MapReceiptDescription.get(RRI.Receipt_Number__c).Revenue_Classification__c;
			}
		}
		RA_Receipt_Invoice_TriggerHelper.PopulateAccount(TriggerNew);
    }
    public static void Execute_AI(list<RA_Receipt_Invoice__c> TriggerNew){
		RA_Receipt_Invoice_TriggerHelper.Create_Receipt_Invoice(TriggerNew);
    }
    public static void Execute_BU(list<RA_Receipt_Invoice__c> TriggerNew,map<Id,RA_Receipt_Invoice__c> TriggerOld){
		//RA_Receipt_Invoice_TriggerHelper.PopulateAccount(TriggerNew);
		set<string> setReceiptNumbers = new set<string>();
		map<string,Receipt_Description__c> MapReceiptDescription = new map<string,Receipt_Description__c>();
		for(RA_Receipt_Invoice__c RRI:TriggerNew){
			if(RRI.Receipt_Number__c!=null && RRI.Receipt_Description__c==null)
				setReceiptNumbers.add(RRI.Receipt_Number__c);
		}
		if(setReceiptNumbers.size()>0){
			for(Receipt_Description__c RD:[Select Id,Receipt_Number__c,Description__c,Revenue_Classification__c from Receipt_Description__c where Receipt_Number__c IN:setReceiptNumbers]){
				MapReceiptDescription.put(RD.Receipt_Number__c,RD);
			}
		}
		for(RA_Receipt_Invoice__c RRI:TriggerNew){
			if(RRI.Receipt_Number__c!=null && MapReceiptDescription.get(RRI.Receipt_Number__c)!=null){
				RRI.Receipt_Description__c = MapReceiptDescription.get(RRI.Receipt_Number__c).Id;
				RRI.Revenue_Classification__c = MapReceiptDescription.get(RRI.Receipt_Number__c).Revenue_Classification__c;
			}
		}
    }
    public static void Execute_AU(list<RA_Receipt_Invoice__c> TriggerNew,map<Id,RA_Receipt_Invoice__c> TriggerOld){
		set<string> SetRARI = new set<string>();
		for(RA_Receipt_Invoice__c RARI:TriggerNew){
			if(RARI.Total_Paid_in_USD__c!=TriggerOld.get(RARI.Id).Total_Paid_in_USD__c){
				SetRARI.add(RARI.Id);
			}
		}
		if(SetRARI.size()>0){
			list<Related_Invoice_Receipt__c> lstRelatedInvRecpt = new list<Related_Invoice_Receipt__c>();
			map<string,Receipt__c> MapReceipts = new map<string,Receipt__c>();
			for(Related_Invoice_Receipt__c objRel:[Select Id,Amount_Applied__c,Receipt__c,RA_Receipt_Invoice__r.Total_Paid_in_USD__c from Related_Invoice_Receipt__c where RA_Receipt_Invoice__c IN:SetRARI]){
				objRel.Amount_Applied__c = objRel.RA_Receipt_Invoice__r.Total_Paid_in_USD__c;
				Receipt__c objReceipt = new Receipt__c(Id=objRel.Receipt__c,Amount__c=objRel.Amount_Applied__c);
				MapReceipts.put(objReceipt.Id,objReceipt);
				lstRelatedInvRecpt.add(objRel);
			}
			try{
				if(MapReceipts.size()>0)
					update MapReceipts.values();
				if(lstRelatedInvRecpt.size()>0)
					update lstRelatedInvRecpt;
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
}