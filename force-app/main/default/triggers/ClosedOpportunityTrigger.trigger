trigger ClosedOpportunityTrigger on Opportunity(after insert, after update){
    List<task> testtask = new List<task>();  
    for (Opportunity opp :[SELECT Id,StageName FROM Opportunity WHERE StageName='Closed Won' AND Id in :Trigger.new]){                 
            
        testtask.add(new Task(Subject = 'Follow On Test Task',WhatId = opp.Id));
    }
    if(testtask.size()>0){
        insert testtask;
        
    }
    
}