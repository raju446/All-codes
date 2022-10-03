public class UpdateFirstContactDetails{
    @InvocableMethod(label='Populate First Contact Details' description='Update First Contact Details on Lead')
    public static void updateLead(List<Id> emailMessageId){
        List<EmailMessageRelation> objEMRList = [SELECT Id, RelationId FROM EmailMessageRelation WHERE EmailMessageId IN :emailMessageId];
        
        if(objEMRList != null){
            Set<Id> leadIds = new Set<Id>();
            for(EmailMessageRelation objEMR : objEMRList){
                if(objEMR.RelationId != null){
                    String relIdStr = objEMR.RelationId;
                    if(relIdStr.substring(0,3) == '00Q'){
                        leadIds.add(objEMR.RelationId);
                    }
                }
            }
            
            if(!leadIds.isEmpty()){
                Map<Id,Lead> leadContactMap = new Map<Id,Lead>();
                List<Lead> relatedLeadUpdates = new List<Lead>();
                for(Lead objLead : [SELECT Id, First_Contact_Date__c,Related_Lead_Entity__c FROM Lead WHERE Id IN :leadIds AND First_Contact_Date__c = null]){
                    objLead.First_Contact_Date__c = Date.Today();
                    if(objLead.Related_Lead_Entity__c != null){
                        leadContactMap.put(objLead.Related_Lead_Entity__c,objLead);
                    }
                    
                    relatedLeadUpdates.add(objLead);
                }
                
                for(Lead objLeadEntity :[SELECT Id, First_Contact_Date__c FROM Lead WHERE Id IN :leadContactMap.keyset() AND First_Contact_Date__c = null]){
                    if(leadContactMap.containskey(objLeadEntity.Id)){
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
}