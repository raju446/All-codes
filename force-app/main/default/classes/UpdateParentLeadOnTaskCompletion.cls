public class UpdateParentLeadOnTaskCompletion {
    //Invoked from Process Builder - [CRM - Contact Date]
    //Populate Parent Lead (First and Last) Contact Details if the Task is completed.
    @InvocableMethod(label='Populate Parent Lead Last Contact Details' description='Update Parent Lead Last Contact Details on Lead')
    public static void updateParentLeadLastContactDate(List<Id> taskId){
        String sub;
        Set<Id> leadIds = new Set<Id>();
        for(Task t : [Select Id, WhoId from Task where id in :taskId])
        {
            sub = t.WhoId;
            if (sub != null && sub.substring(0, 3) == '00Q') 
                leadIds.add(t.WhoId);
        }
        System.debug('leadIds>>>>>'+leadIds);   
        if(!leadIds.isEmpty()){
            Map<Id,Lead> leadContactMap = new Map<Id,Lead>();//Adds the related Lead Entity and the associated Contact.
            List<Lead> relatedLeadUpdates = new List<Lead>();
            for(Lead objLead : [SELECT Id, Last_Contact_Date__c,First_Contact_Date__c,Related_Lead_Entity__c,Related_Lead_Entity__r.Last_Contact_Date__c FROM Lead WHERE Id IN :leadIds and Related_Lead_Entity__c != null]){
                leadContactMap.put(objLead.Related_Lead_Entity__c,objLead);
                
            }
            for(Lead objLeadEntity :[SELECT Id, Last_Contact_Date__c,First_Contact_Date__c FROM Lead WHERE Id IN :leadContactMap.keyset()]){
                if(leadContactMap.containskey(objLeadEntity.Id)){
                    objLeadEntity.Last_Contact_Date__c = leadContactMap.get(objLeadEntity.Id).Last_Contact_Date__c;
                    if(objLeadEntity.First_Contact_Date__c == null) //Update the Lead Entity [first contacted date] with the leadcontacts[first contacted date] value if it is blank in the LEad Entity
                        objLeadEntity.First_Contact_Date__c = leadContactMap.get(objLeadEntity.Id).First_Contact_Date__c;
                    relatedLeadUpdates.add(objLeadEntity);
                }
            }
            
            if(!relatedLeadUpdates.isEmpty()){
                update relatedLeadUpdates;
            }
        }
    }
}