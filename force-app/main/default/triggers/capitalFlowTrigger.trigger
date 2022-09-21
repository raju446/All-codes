trigger capitalFlowTrigger on CapitalFlow__c (after insert) {
if(trigger.isInsert && trigger.isAfter){
  list<Delta__c> dtList = new list<Delta__c>();
     for(CapitalFlow__c cf: trigger.new){
         if(cf.Type__c == 'Subscription'){
             Delta__c dt = new Delta__c();
             dt.Name = cf.Name;
             dt.Amount__c = cf.Amount__c;
             dt.Type__c = cf.Type__c;
             dt.Date__c = cf.Date__c;
             dtList.add(dt);
         }
         if(cf.Type__c == 'Redemption'){
            Delta__c dt = new Delta__c();
             dt.Name = cf.Name;
             dt.Amount__c = cf.Amount__c * -1;
             dt.Type__c = cf.Type__c;
             dt.Date__c = cf.Date__c;
             dtList.add(dt);
         }
     }
     if(dtList.size()>0){
        database.insert(dtList,false);        
     }
   }  
   
}