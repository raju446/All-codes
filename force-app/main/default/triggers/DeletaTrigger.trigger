trigger DeletaTrigger on Delta__c (before insert) {
   set<date> dtDate = new set<date>();  
   set<string> dtType = new set<string>();  
   for(Delta__c dt: trigger.new){
       if(dt.Type__c != null){
          dtType.add(dt.Type__c);
       }
       if(dt.Date__c != null){
           dtDate.add(dt.Date__c);
       }
   }
   set<string> valueExisting = new set<string>();
   for(Delta__c dt: [select id,Type__c,Date__c from Delta__c where Type__c in: dtType or Date__c in: dtDate]){
     valueExisting.add(string.valueof(dt.Date__c) + '-' + dt.Type__c);
    }
   for(Delta__c dt: trigger.new){
       if(valueExisting.contains(string.valueof(dt.Date__c) + '-' + dt.Type__c)){
          dt.addError('No Two Delta Reecords can have same Date and Type');
       }
    }   
}