trigger studentcount on student2__c (before insert) {
    if(trigger.isinsert){
        if(trigger.isbefore)
    for(student2__c ui:trigger.new){
        if(ui.gender__c=='Male'){
            ui.marks__c=50;
            ui.fees__c=100000;
            ui.results__c='pass';
            
        } 
    }
  }
}