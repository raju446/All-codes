global class Batch_UpdateLicenseNumber implements Database.Batchable<sObject>,Schedulable  {
    global void execute(SchedulableContext sc) {
        database.executebatch(this,1); 
    } 
        
    //Get All the CRM Accounts where License/Enity ID is blank and Pre-Application Number is not blank
    global Database.QueryLocator start(Database.BatchableContext bc) {
        map<String,ID> accountRecordTypeMap=ApexCodeUtility.getRecTypeDetails('Account');
        //Get All the CRM Accounts where License/Enity ID is blank and Pre-Application Number is not blank
        String query = 'SELECT Id,CRM_Pre_Approval_Id__c FROM Account where CRM_Entity_Id__c=null and CRM_Pre_Approval_Id__c!=null and recordTypeID=\''+accountRecordTypeMap.get('CRM Registered Entity')+'\'';
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> records){
        map<String,ID> accountRecordTypeMap=ApexCodeUtility.getRecTypeDetails('Account');
        system.debug('**'+accountRecordTypeMap);
        //Try to get the information from the custom object and update the account
        map<String,Catalyst_Entity__c> preApplicationToEntityID = new map<String,Catalyst_Entity__c>();
        for(Account tempAcc:records){
            preApplicationToEntityID.put(tempAcc.CRM_Pre_Approval_Id__c,null);
        }
        map<string,Account> registeredCompanyMap = new map<string,Account>();
        set<String> entityIDSet=new set<String>();
        for(Catalyst_Entity__c tempRec : [select id,Entity_id__c,Preapplication_number__c from Catalyst_Entity__c where Preapplication_number__c in :preApplicationToEntityID.keySet()]){
            preApplicationToEntityID.put(tempRec.Preapplication_number__c,tempRec);
            entityIDSet.add(tempRec.Entity_id__c);
        }
        for(Account acc : [select Id,Name,Entity_Status__c,Entity_Id__c,Registration_Date__c,License_Expiry_Date__c from Account where Entity_id__c in :entityIDSet and recordTypeID = :accountRecordTypeMap.get('ADGM Registered Company') ]){
            registeredCompanyMap.put(acc.Entity_id__c,acc);
        }
        
        list<Account> accToUpdate = new list<Account>();
        for(Account tempAcc : records){
            if(preApplicationToEntityID.containsKey(tempAcc.CRM_Pre_Approval_Id__c) && preApplicationToEntityID.get(tempAcc.CRM_Pre_Approval_Id__c)!=null && preApplicationToEntityID.get(tempAcc.CRM_Pre_Approval_Id__c).Entity_id__c!=null){
                    string licenseNumber = preApplicationToEntityID.get(tempAcc.CRM_Pre_Approval_Id__c).Entity_id__c;
                    string accountStatus = (registeredCompanyMap.containsKey(licenseNumber) && registeredCompanyMap.get(licenseNumber).Entity_Status__c !=null)?registeredCompanyMap.get(licenseNumber).Entity_Status__c:'';
                    Account accTBU = new Account();
                    accTBU.Id = tempAcc.Id;
                    accTBU.CRM_Entity_Id__c = licenseNumber;
                    accTBU.Entity_Status__c = accountStatus;
                    if(registeredCompanyMap.get(licenseNumber)!=null){
                        accTBU.Name = registeredCompanyMap.get(licenseNumber).Name;
                        accTBU.Registration_Date__c = registeredCompanyMap.get(licenseNumber).Registration_Date__c;
                        accTBU.License_Expiry_Date__c = registeredCompanyMap.get(licenseNumber).License_Expiry_Date__c;
                    }
                    accToUpdate.add(accTBU);
                }
        }
        try{
            if(accToUpdate.size()>0)
                update accToUpdate;
        }catch(Exception e){
            
        }
        
        //Once the Business application is approved the entry will be created in Catalyst object with below details
        //    Entity_type = PREAPPLICATION
        //    Status = active
        //    Entity_id = <variable value from business>
        map<String,Account> preApplicationToEntityMap = new map<String,Account>();
        for(Account tempAcc:records){
            preApplicationToEntityMap.put(tempAcc.CRM_Pre_Approval_Id__c,tempAcc);
        }
        set<ID> accountsToProcess = new set<ID>();
        for(Catalyst_Entity__c tempRec : [select id,Entity_id__c,Preapplication_number__c from Catalyst_Entity__c where Entity_Id__c in :preApplicationToEntityMap.keySet() and Entity_type__c='PREAPPLICATION' and Status__c='Active']){
            accountsToProcess.add(preApplicationToEntityMap.get(tempRec.Entity_Id__c).Id);
        }
        list<opportunity> opportunityToUpdate = new list<opportunity>();
        for(opportunity opty : [select id from opportunity where AccountID in :accountsToProcess]){
            opportunityToUpdate.add(new opportunity(id=opty.id,Pre_Application_Approved__c=true));
        }
        //Notification Trigger
        if(!opportunityToUpdate.isEmpty()){
            update opportunityToUpdate;
        }
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}