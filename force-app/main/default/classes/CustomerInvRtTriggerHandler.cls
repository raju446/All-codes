public without sharing class CustomerInvRtTriggerHandler{
    public static void Execute_BI(list<Customer_Invoice_Receipt__c> TriggerNew){
        map<string,Account> MapOU = new map<string,Account>();
        set<string> AccountIds = new set<string>();
        for(Customer_Invoice_Receipt__c CIR:TriggerNew){
            if(CIR.Entity__c!=null)
                AccountIds.add(CIR.Entity__c);
        }
        if(AccountIds.size()>0){
            for(Account acc:[Select Id,Operating_Unit__c,Operating_Unit__r.OU_Abbreviation__c from Account where Id IN:AccountIds]){
                MapOU.put(acc.Id,acc);
            }
        }
        for(Customer_Invoice_Receipt__c CIR:TriggerNew){
            if(CIR.Entity__c!=null && MapOU.get(CIR.Entity__c)!=null){
                CIR.Operating_Unit_Lookup__c = MapOU.get(CIR.Entity__c).Operating_Unit__c;
                if(MapOU.get(CIR.Entity__c).Operating_Unit__c!=null)
                    CIR.Sys_OU_Code__c = MapOU.get(CIR.Entity__c).Operating_Unit__r.OU_Abbreviation__c;
            }
        }
    }
    
    public static void Execute_BU(list<Customer_Invoice_Receipt__c> TriggerNew,map<Id,Customer_Invoice_Receipt__c> TriggerOld){
        map<string,Account> MapOU = new map<string,Account>();
        set<string> AccountIds = new set<string>();
        for(Customer_Invoice_Receipt__c CIR:TriggerNew){
            if(CIR.Entity__c!=null && CIR.Sys_OU_Code__c==null)
                AccountIds.add(CIR.Entity__c);
        }
        if(AccountIds.size()>0){
            for(Account acc:[Select Id,Operating_Unit__c,Operating_Unit__r.OU_Abbreviation__c from Account where Id IN:AccountIds]){
                MapOU.put(acc.Id,acc);
            }
        }
        for(Customer_Invoice_Receipt__c CIR:TriggerNew){
            if(CIR.Entity__c!=null && CIR.Sys_OU_Code__c==null && MapOU.get(CIR.Entity__c)!=null){
                CIR.Operating_Unit_Lookup__c = MapOU.get(CIR.Entity__c).Operating_Unit__c;
                if(MapOU.get(CIR.Entity__c).Operating_Unit__c!=null)
                    CIR.Sys_OU_Code__c = MapOU.get(CIR.Entity__c).Operating_Unit__r.OU_Abbreviation__c;
            }
        }
    }
}