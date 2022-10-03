/*
*Author : Azmath
Description : This class is a heper class for participanttriggerhandler class.
*/
public without sharing class ParticipantTriggerHelper 
{
	/*
	* Method : createplaceholder
	* Description : This method will create a document place holder for the clients to upload commercial license of contractors..
	*/
    public static void createplaceholder(list<Amendment__c> participants,map<id,Amendment__c> oldmap,boolean isNew)
    {
        set<string> contractorslist = new set<string>();
        set<string> oldContractorslist = new set<string>();
        set<id> srs = new set<id>();
        
        for(Amendment__c am : participants)
        {
            if(am.Contractor_Name__c != null){
                if(isNew)
                    srs.add(am.Service_Request__c);
                else{
                    if(oldmap.get(am.id).Contractor_Name__c != am.Contractor_Name__c){
                        oldContractorslist.add(oldmap.get(am.id).Contractor_Name__c);
                        srs.add(am.Service_Request__c);
                    }
                }
            }
        }
        system.debug('========'+oldContractorslist);
        if(!srs.isEmpty())
        {
            try {
                //1. Query all the contractors..
                for(HexaBPM__SR_Doc__c srDoc : [Select Contractor__c from HexaBPM__SR_Doc__c WHERE HexaBPM__Service_Request__c IN:srs]){
                    contractorslist.add(srDoc.Contractor__c);
                }
                
                list<HexaBPM__SR_Doc__c> insertCommercialLicensedocs = new list<HexaBPM__SR_Doc__c>();
                list<HexaBPM__SR_Template_Docs__c> tempDoc = [Select id, HexaBPM__Document_Master__r.Name, HexaBPM__Document_Master_Code__c, HexaBPM__Document_Master__c 
                                                                FROM HexaBPM__SR_Template_Docs__c WHERE HexaBPM__Document_Master__r.Name='Commercial License Copy'
                                                                    AND HexaBPM__SR_Template__r.HexaBPM__SR_RecordType_API_Name__c='Temporary_Fit_Out_Security_Clearance' limit 1];
                for(Amendment__c am : participants)
                {
                    if(!contractorslist.contains(am.Contractor_Name__c))
                    {
                        HexaBPM__SR_Doc__c srDoc            = new HexaBPM__SR_Doc__c();
                        srDoc.HexaBPM__From_Finalize__c     = true;
                        srDoc.Contractor__c                 = am.Contractor_Name__c;
                        if(!tempDoc.isEmpty()){
                            srDoc.Name                          = tempDoc[0].HexaBPM__Document_Master__r.Name;
                            srDoc.HexaBPM__Document_Master__c   = tempDoc[0].HexaBPM__Document_Master__c;
                            srDoc.HexaBPM__SR_Template_Doc__c   = tempDoc[0].id;
                        }else{
                            srDoc.Name ='Document do not exists.';
                        }
                        srDoc.HexaBPM__Service_Request__c   = am.Service_Request__c;
                        srDoc.HexaBPM__Status__c            = 'Pending Upload';
                        srDoc.HexaBPM__Document_Description_External__c = 'Please upload '+am.Contractor_Name__c+'\'s Commercial License copy';
                        insertCommercialLicensedocs.add(srDoc);
                    }
                }
                if(!insertCommercialLicensedocs.isEmpty())
                {
                    insert insertCommercialLicensedocs;
                    
                    list<Amendment__c> partps = [Select id from Amendment__c where Contractor_Name__c IN:oldContractorslist and Service_Request__c IN:srs];
                    if(partps.isEmpty()){
                        list<HexaBPM__SR_Doc__c> deleteSrDocs = [Select id from HexaBPM__SR_Doc__c where Contractor__c IN:oldContractorslist and HexaBPM__Service_Request__c IN:srs];
                        delete deleteSrDocs;
                    }
                }
            }catch(exception ex){
                system.debug('===exception is==='+ex.getMessage());
            }
        }
    
    }
	/*
	* Method  : Azmath
	* Description : This method will take care of deleting the SR docs of particpant when removed.
	*/
    public static void deleteSRDoc(list<Amendment__c> participants)
    {
        try{
            system.debug('==delete===');
            set<string> contractors = new set<string>();
            set<id> srids = new set<id>();
            for(Amendment__c am :participants){
                if(am.Contractor_Name__c != null)
                    contractors.add(am.Contractor_Name__c);
                    srids.add(am.Service_Request__c);
            }
            if(!contractors.isEmpty())
            {
                list<Amendment__c> partps = [Select id from Amendment__c where Contractor_Name__c IN:contractors and ID NOT IN:participants and Service_Request__c IN:srids];
                if(partps.isEmpty()){
                    list<HexaBPM__SR_Doc__c> deleteSrDocs = [Select id from HexaBPM__SR_Doc__c where Contractor__c IN:contractors and HexaBPM__Service_Request__c IN:srids];
                    delete deleteSrDocs;
                }
            }
        }catch(Exception ex){
            system.debug('==exception is=='+ex.getMessage());
        }
    }
    /*public static void mapParentSR(list<Amendment__c> participants)
    {
        set<id> srids = new set<id>();
        map<id,id> parentSRMap = new map<id,id>();
        for(Amendment__c am :participants){
            srids.add(am.Service_Request__c);
        }
        for(HexaBPM__Service_Request__c sr :[Select id, HexaBPM__Parent_SR__c from HexaBPM__Service_Request__c where ID IN:srids])
        {
            if(sr.HexaBPM__Parent_SR__c != null)
            {
                parentSRMap.put(sr.id,sr.HexaBPM__Parent_SR__c);
            }
        }
        if(!parentSRMap.isEmpty()){
            for(Amendment__c am :participants)
            {
                if(parentSRMap.containsKey(am.Service_Request__c)){
                    am.Parent_SR__c = parentSRMap.get(am.Service_Request__c);
                }
            }
        }
    }*/
}