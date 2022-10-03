global without sharing class QueueableUtils implements Queueable, Database.AllowsCallouts {
	
    public string recordId, DocumentMasterId;
    
    public void execute(QueueableContext context) {
        generateDocument(recordId, DocumentMasterId);
    }
    
    public static void generateDocument(string recordId, string DocumentMasterId){
        string ddpId, deliverayOptionId;
        for(HexaBPM__Document_Master__c objDM : [select Id,DDP_Letter_Template__c,DDP_Letter_Template__r.Loop__DDP__c from HexaBPM__Document_Master__c where Id=:DocumentMasterId]){
            ddpId = objDM.DDP_Letter_Template__r.Loop__DDP__c;
            deliverayOptionId = objDM.DDP_Letter_Template__c;
        }
        if(deliverayOptionId != null){
            Map<string, string> variables = new Map<string, string> {
                'deploy' => deliverayOptionId,
                'SFInvoice__c' => recordId
			};
            //Loop.loopMessage.send(recordId,ddpId,variables, 'cs80');
            Loop.loopMessage lm = new Loop.loopMessage();
            lm.sessionId = System.Label.BM_Queable_Session_Id;//'00D25000000DxwU!AQYAQNXPBdbhlEs9TBG4620JAevfGBYpCKPoHv06V1NOt5DbGSjZxuHKDNjX7w9hE_3ON0zmWe4mtl74uulRRau1.7.GmSSo';//UserInfo.getSessionId();
            lm.requests.add(
                new Loop.loopMessage.loopMessageRequest(
                    recordId,
                    ddpId,
                    variables
                )
            );
            lm.sendAllRequests();
        }
    }
    
}