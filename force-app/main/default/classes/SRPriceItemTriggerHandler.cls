/*
    Author      : Kim Noceda
    Date        : 14-Jan-2018
    Description : Trigger handler class that is being referenced in the SRPriceItemTrigger.
                  All DML methods are being handled in this handler class.
    * @Change History
    * Version    Author             Date            Description
      v1.1       Yogesh Mahajan     04/08/2019      Added invoice creation logic in Execute_BU and Execute_BI.
      v1.2      Yogesh Mahajan      18/08/2019      Added after update method to store field history for log text fields.
    --------------------------------------------------------------------------------------
*/
public without sharing class SRPriceItemTriggerHandler {
    private static boolean isUpdatedFirstTime = true;
    
    public static void Execute_BI(list<HexaBPM__SR_Price_Item__c> TriggerNew){
        PopulateEntity(TriggerNew);
        CalculateTaxes(TriggerNew);
        if(System.Label.BM_SRPriceItemTriggerHandler == 'Yes'){
            reduceTax(TriggerNew);
            // invoice creation if not exit
            SRPriceItemTriggerHelper.linkInvoiceToSRPriceIteam(TriggerNew, false);
            SRPriceItemTriggerHelper.populateRevenueMapping(TriggerNew);
        }  
    }
    public static void Execute_AI(list<HexaBPM__SR_Price_Item__c> TriggerNew){
        system.debug('Execute_AI----');
        // invoice creation/ updation
        //SRPriceItemTriggerHelper.createInvoiceLineItem(TriggerNew, false);
    }
    public static void Execute_BU(map<Id,HexaBPM__SR_Price_Item__c> TriggerNewMap,map<Id,HexaBPM__SR_Price_Item__c> TriggerOldMap){
        ReCalculateCancellationFee(TriggerNewMap,TriggerOldMap);
        if(System.Label.BM_SRPriceItemTriggerHandler == 'Yes'){
            if(isUpdatedFirstTime) {
                isUpdatedFirstTime = false;
                system.debug('SRPriceItem Execute_AU----->');
                // invoice creation if not exit
                SRPriceItemTriggerHelper.linkInvoiceToSRPriceIteam(TriggerNewMap.values(), true);
                SRPriceItemTriggerHelper.populateRevenueMapping(TriggerNewMap.values());
            }
        }        
    }
    public static void Execute_AU(map<Id,HexaBPM__SR_Price_Item__c> TriggerNewMap,map<Id,HexaBPM__SR_Price_Item__c> TriggerOldMap){
        if(isUpdatedFirstTime) {  
            isUpdatedFirstTime = false;
            CustomAuditHistoryTracking.addSRPriceItemAuditHistory(TriggerOldMap, TriggerNewMap.values());
        }
        // invoice creation/ updation
        //SRPriceItemTriggerHelper.createInvoiceLineItem(TriggerNewMap.values(), true);
    }
    
    
    
    /*
        Method Name :   ReCalculateCancellationFee
        Description :   Method to re-calculate the cancellation fee
    */
    public static void ReCalculateCancellationFee(map<Id,HexaBPM__SR_Price_Item__c> TriggerNewMap,map<Id,HexaBPM__SR_Price_Item__c> TriggerOldMap){
        for(HexaBPM__SR_Price_Item__c objPriceItem : TriggerNewMap.values()){
            if(objPriceItem.Is_Refund_Line__c && objPriceItem.Cancellation_Fee__c!=TriggerOldMap.get(objPriceItem.Id).Cancellation_Fee__c){
                decimal NewCancellationFee = 0;
                decimal OldCancellationFee = 0;
                if(objPriceItem.Cancellation_Fee__c!=null)
                    NewCancellationFee = objPriceItem.Cancellation_Fee__c;
                if(TriggerOldMap.get(objPriceItem.Id).Cancellation_Fee__c!=null)
                    OldCancellationFee = TriggerOldMap.get(objPriceItem.Id).Cancellation_Fee__c;
                decimal DiffCancelFeeAmount = 0;
                if(NewCancellationFee > OldCancellationFee)
                    DiffCancelFeeAmount = NewCancellationFee - OldCancellationFee;
                else
                    DiffCancelFeeAmount = (OldCancellationFee - NewCancellationFee) * -1;
                if(DiffCancelFeeAmount!=null)
                    objPriceItem.HexaBPM__Price__c = objPriceItem.HexaBPM__Price__c + DiffCancelFeeAmount;
            }
        }
    }
    
    
    /*
        Method Name :   PopulateEntity
        Description :   Method to populate Entity lookup field from the from SR Entity
    */
    public static void PopulateEntity(list<HexaBPM__SR_Price_Item__c> srPriceItemList){
        for(HexaBPM__SR_Price_Item__c objPriceItem : srPriceItemList){
            system.debug('in SRPriceItemTriggerHandler'+objPriceItem);
           /* if(objPriceItem.Fee__c!=0 && objPriceItem.Service_Request_Name__c=='P.O.Box - New Application'){
            	HexaBPM__Pricing_Line__c lst = [SELECT id from HexaBPM__Pricing_Line__c where Id=:objPriceItem.HexaBPM__Pricing_Line__c];
                if(lst.size()>0){
                    objPriceItem.=lst[0]
                }
            }*/
            
            objPriceItem.Entity__c = objPriceItem.Entity_Id__c;
        }
    }
    
    /*
        Method Name :   CalculateTaxes
        Description :   Method to populate Cost,Markup Amount and VAT Amount
    */
    public static void CalculateTaxes(list<HexaBPM__SR_Price_Item__c> srPriceItemList)
    {
        map<string,HexaBPM__Pricing_Line__c> MapPricingLines = new map<string,HexaBPM__Pricing_Line__c>();
        set<string> setPricingLineIds = new set<string>();
        set<date> setSRCreatedDates = new set<date>();
        set<string> setEntityIds = new set<string>();
        set<string> setSRTemplateIds = new set<string>();
        
        for(HexaBPM__SR_Price_Item__c objPriceItem : srPriceItemList)
        {
            system.debug('*******'+objPriceItem.Entity__c+'*******'+objPriceItem.Is_ADGM_Company__c);
            if(objPriceItem.HexaBPM__Pricing_Line__c!=null)
                setPricingLineIds.add(objPriceItem.HexaBPM__Pricing_Line__c);
            setSRCreatedDates.add(objPriceItem.SR_Created_Date__c);
            if(objPriceItem.Entity_Id__c!=null)
                setEntityIds.add(objPriceItem.Entity_Id__c);
            if(objPriceItem.SR_Template_Id__c!=null)
                setSRTemplateIds.add(objPriceItem.SR_Template_Id__c);
        }
        if(setPricingLineIds.size()>0 && setSRCreatedDates.size()>0){
            for(HexaBPM__Pricing_Line__c PL:[Select Id,Is_Refund_Line__c,Monthly_Charge__c,(select Id,Cancellation_Fee__c,Cost__c,HexaBPM__Unit_Price__c,VAT_Amount__c,MarkupAmount__c,HexaBPM__Date_From__c,HexaBPM__Date_To__c from HexaBPM__Dated_Pricing__r) from HexaBPM__Pricing_Line__c where Id IN:setPricingLineIds]){
                MapPricingLines.put(PL.Id,PL);
            }
        }
        
        map<string,Discount__c> mapDiscountDetails = new map<string,Discount__c>();
        if(setSRTemplateIds.size()>0 && setEntityIds.size()>0){
            for(Discount__c dsc:[Select Id,Start_Date__c,End_Date__c,Discount__c,SR_Template__c,Entity__c from Discount__c where Entity__c IN:setEntityIds and SR_Template__c IN:setSRTemplateIds and Start_Date__c<=:system.today() and End_Date__c>=:system.today()]){
                if(dsc.Entity__c!=null && dsc.SR_Template__c!=null)
                    mapDiscountDetails.put(string.valueof(dsc.Entity__c).substring(0,15)+'-'+string.valueof(dsc.SR_Template__c).substring(0,15),dsc);
            }
        }
        
        for(HexaBPM__SR_Price_Item__c objPriceItem : srPriceItemList){          
            if(objPriceItem.HexaBPM__Pricing_Line__c!=null && MapPricingLines.get(objPriceItem.HexaBPM__Pricing_Line__c)!=null){
                HexaBPM__Pricing_Line__c objPricingLine = MapPricingLines.get(objPriceItem.HexaBPM__Pricing_Line__c);
                if(objPricingLine.HexaBPM__Dated_Pricing__r!=null){
                  objPriceItem.Monthly_Charge__c = objPricingLine.Monthly_Charge__c;
                    for(HexaBPM__Dated_Pricing__c DP:objPricingLine.HexaBPM__Dated_Pricing__r){
                        if(DP.HexaBPM__Date_From__c!=null && DP.HexaBPM__Date_From__c<=objPriceItem.SR_Created_Date__c && DP.HexaBPM__Date_To__c!=null && DP.HexaBPM__Date_To__c>=objPriceItem.SR_Created_Date__c && DP.HexaBPM__Unit_Price__c==objPriceItem.HexaBPM__Price__c){
                            decimal Number_Of_Months = 1;
                            if(objPriceItem.Monthly_Charge__c && objPriceItem.Permit_Months__c!=null && objPriceItem.Permit_Months__c>0)
                                Number_Of_Months = objPriceItem.Permit_Months__c;
                            objPriceItem.HexaBPM__Price__c = objPriceItem.HexaBPM__Price__c * Number_Of_Months;
                            
                            if(System.Label.BM_SRPriceItemTriggerHandler == 'Yes'){
                                if(objPriceItem.Is_SR_Rejected__c == false)
                                	objPriceItem.Cancellation_Fee__c = DP.Cancellation_Fee__c;
                            } else {
                                objPriceItem.Cancellation_Fee__c = DP.Cancellation_Fee__c;
                            }
                            
                                
                            if(DP.VAT_Amount__c!=null)
                                objPriceItem.Tax_Amount__c = DP.VAT_Amount__c * Number_Of_Months;
                            if(DP.Cost__c!=null){
                                objPriceItem.Cost__c = DP.Cost__c * Number_Of_Months;
                                // if Agent is added on PO Box Service requests, add agent 100 D fees to cost
                                /*List<HexaBPM__Service_Request__c> SRObj = [SELECT id, Agent_Name__c, HexaBPM__Record_Type_Name__c from HexaBPM__Service_Request__c where Id=: objPriceItem.HexaBPM__ServiceRequest__c AND Agent_Name__c!=null AND (HexaBPM__Record_Type_Name__c ='P_O_Box_New' OR  HexaBPM__Record_Type_Name__c ='P_O_Box_Renewal') ];
                                system.debug('SRObj==razi=>'+SRObj);
                                if(SRObj.size()>0){
                                    objPriceItem.Cost__c =  objPriceItem.Cost__c+100;
                                }*/
                            }
                            if(DP.MarkupAmount__c!=null)
                                objPriceItem.Markup_Amount__c = DP.MarkupAmount__c * Number_Of_Months;
                            objPriceItem.Is_Refund_Line__c = objPricingLine.Is_Refund_Line__c;
                            if(objPriceItem.Is_Refund_Line__c){
                                objPriceItem.HexaBPM__Price__c = objPriceItem.HexaBPM__Price__c * -1 * Number_Of_Months;
                                if(objPriceItem.Tax_Amount__c!=null)
                                    objPriceItem.Tax_Amount__c = objPriceItem.Tax_Amount__c * -1 * Number_Of_Months;
                                if(objPriceItem.Cost__c!=null)
                                    objPriceItem.Cost__c = objPriceItem.Cost__c * -1 * Number_Of_Months;                                    
                                if(objPriceItem.Markup_Amount__c!=null)
                                    objPriceItem.Markup_Amount__c = objPriceItem.Markup_Amount__c * -1 * Number_Of_Months;
                                if(objPriceItem.Cancellation_Fee__c!=null)
                                    objPriceItem.HexaBPM__Price__c = objPriceItem.HexaBPM__Price__c + objPriceItem.Cancellation_Fee__c; 
                            }
                            break;
                        }
                    }
                }
            }
        }
        
        for(HexaBPM__SR_Price_Item__c objPriceItem : srPriceItemList)
        {
            if(objPriceItem.Markup_Amount__c!=null && mapDiscountDetails.get(objPriceItem.Entity_Id__c+'-'+objPriceItem.SR_Template_Id__c)!=null && mapDiscountDetails.get(objPriceItem.Entity_Id__c+'-'+objPriceItem.SR_Template_Id__c).Discount__c!=null)
            {
                Discount__c objDiscount = mapDiscountDetails.get(objPriceItem.Entity_Id__c+'-'+objPriceItem.SR_Template_Id__c);
                objPriceItem.Discount__c = objPriceItem.Markup_Amount__c * objDiscount.Discount__c / 100;
                objPriceItem.Markup_Amount__c = (objPriceItem.Markup_Amount__c * (100-objDiscount.Discount__c)/100).setScale(2);
                
                decimal TaxAmountDiscount = 0;
                if(objPriceItem.Tax_Amount__c!=null){
                    objPriceItem.Tax_Amount__c = (objPriceItem.Tax_Amount__c * (100-objDiscount.Discount__c)/100).setScale(2);
                    TaxAmountDiscount = objPriceItem.Tax_Amount__c * objDiscount.Discount__c / 100;
                }
                objPriceItem.Discount__c = objPriceItem.Discount__c + TaxAmountDiscount;
            }
            
            //Note: The below condition has to be executed last always. So if any user wants to add any code make sure to execute 
            // this condition at last.
            
            if(objPriceItem.Is_ADGM_Company__c == true)
            {
                objPriceItem.Actual_Cost__c             = objPriceItem.Cost__c;
                objPriceItem.Actual_Cancellation_Fee__c = objPriceItem.Cancellation_Fee__c;
                objPriceItem.Actual_Markup_Amount__c    = objPriceItem.Markup_Amount__c ;
                objPriceItem.Actual_Tax_Amount__c       = objPriceItem.Tax_Amount__c;
                
                objPriceItem.Cost__c = 0;
                objPriceItem.Cancellation_Fee__c = 0;
                objPriceItem.Discount__c = 0;
                objPriceItem.Markup_Amount__c = 0;
                objPriceItem.HexaBPM__Price__c = 0;
                objPriceItem.Tax_Amount__c = 0;
                
                
                
            }
            
        }
        
    }
    /*
        Method Name :   Reduce Tax
        Description :  
    */
    public static void reduceTax(list<HexaBPM__SR_Price_Item__c> srPriceItemList)
    {
        /*set<id> srids = new set<id>();
        set<id> reduceTaxIds = new set<id>();
        map<id,HexaBPM__Service_Request__c> srmap = new map<id,HexaBPM__Service_Request__c>();
        
        for(HexaBPM__SR_Price_Item__c pi : srPriceItemList)
        {
            if(pi.HexaBPM__ServiceRequest__c != null)
            {
                srids.add(pi.HexaBPM__ServiceRequest__c);
            }
        }
        system.debug('==srids===='+srids);
        if(!srids.isEmpty())
        {
            for(HexaBPM__Service_Request__c sr : [Select Visa_Period__c,HexaBPM__Submitted_Date__c,HexaBPM__External_Status_Name__c from HexaBPM__Service_Request__c where id IN:srids and Visa_Period__c='1' 
                and (HexaBPM__Record_Type_Name__c = 'Employment_Visa_New'  or HexaBPM__Record_Type_Name__c = 'Employment_Visa_Renewal') ])
            {
                reduceTaxIds.add(sr.id);
                srmap.put(sr.id,sr);
            }
        }
        for(HexaBPM__SR_Price_Item__c pi : srPriceItemList)
        {
            if(srmap.containsKey(pi.HexaBPM__ServiceRequest__c) && 
                (srmap.get(pi.HexaBPM__ServiceRequest__c).HexaBPM__Submitted_Date__c == null || pi.Is_Refund_Line__c == true)
              )
            {
                system.debug('===test=='+pi.Invoice_Price_Line_Item__c+'===='+srmap.get(pi.HexaBPM__ServiceRequest__c).HexaBPM__External_Status_Name__c);
                if(srmap.get(pi.HexaBPM__ServiceRequest__c).HexaBPM__Submitted_Date__c == null)
                   pi.Tax_Amount__c = pi.Tax_Amount__c - 15;
                else if(pi.Is_Refund_Line__c == true && pi.Invoice_Price_Line_Item__c != 'Refund ')
                    pi.Tax_Amount__c = pi.Tax_Amount__c + 15;
               
            }
        } */
    }
    
    
}