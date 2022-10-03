/*
//Comments: Set the batch size of this class to 10 as there are api callouts.
*/
global without sharing class Batch_JEsStatusFromOracle implements Database.Batchable<String>, Database.AllowsCallouts, Database.stateful
{
    global map<id,Journal_Header__c> JHMap = new map<id,Journal_Header__c>();
    global Iterable<String> start(Database.BatchableContext BC)
    {
        set<string> reqId_N_instId = new set<string>();
        
        for(Journal_Header__c objJH : [SELECT Id, Oracle_InstanceId__c, Oracle_RequestId__c, Oracle_Status__c 
                                       FROM Journal_Header__c WHERE Oracle_Status__c = 'In Progress' /*AND Oracle_RequestId__c = '1586189' AND Oracle_InstanceId__c = '26491954'*/])
        {
            if(objJH.Oracle_RequestId__c != null && objJH.Oracle_InstanceId__c != null){
                string temp = objJH.Oracle_RequestId__c+'#'+objJH.Oracle_InstanceId__c;
                if(!reqId_N_instId.contains(temp)){
                    reqId_N_instId.add(temp);
                }
                JHMap.put(objJH.id,objJH);
            }
        }
        system.debug('==mapstre=='+JHMap.keySet());
       return (Iterable<String>)reqId_N_instId;
    }
    
    global void execute(Database.BatchableContext BC,list<string> reqId_N_instIds)
    {
        system.debug('list size'+reqId_N_instIds.size());
        map<id,JEsStatusFromOracle.GlJournals> mainmap = new map<id,JEsStatusFromOracle.GlJournals>();
        for(string req : reqId_N_instIds){
            list<string> splitAtt = req.split('#');
        	map<id,JEsStatusFromOracle.GlJournals> result = JEsStatusFromOracle.doCalloutFromFuture(splitAtt[0], splitAtt[1]);
            if(result != null && !result.isEmpty()){
                for(id jhid : result.keyset()){
                    mainmap.put(jhid,result.get(jhid));
                }
            }
        }
        if(!mainmap.isEmpty()){
            list<Journal_Header__c> jlist = new list<Journal_Header__c>();
            for(id recid : mainmap.keyset()){
                if(JHMap.containsKey(recid))
                {
                    JEsStatusFromOracle.GlJournals gi = mainmap.get(recid);
                    Journal_Header__c jh = JHMap.get(recid);
                    if(gi.RequestId == jh.Oracle_RequestId__c && gi.InstanceId == jh.Oracle_InstanceId__c){
                        jh.Oracle_Status__c 			= gi.Status;
                        jh.Oracle_FailedJob__c 			= gi.FailedJob;
                        jh.Oracle_ImportId__c 			= gi.ImportId;
                        jh.Oracle_ImportChildId__c 		= gi.ImportChildId;
                        jh.Oracle_FusionBatchName__c 	= gi.FusionBatchName;
                        jh.Oracle_SfBatchId__c 			= gi.SfBatchId;
                        jh.Oracle_SfBatchName__c 		= gi.SfBatchName;
                        jlist.add(jh);
                    }
                }
            }
            if(!jlist.isEmpty())
                update jlist;
        }
        //system.debug('--map size--'+mainmap.size());
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
}