global class Fusion_MockHttpRespforJEsStatus implements HttpCalloutMock{
	global HttpResponse respond(HttpRequest req)
    {
        string recid = '';
        list<Journal_Header__c> je = [Select id from Journal_Header__c limit 1];
        if(!je.isEmpty()){
            recid = je[0].id;
        }
        system.debug('===mock class=='+recid);
        string body='{ "GlJournals": [{"RequestId": "1234","InstanceId": "1234","Status": "Success","FailedJob": "","ImportId": "1234","ImportChildId": "1234","FusionBatchName": "","SfBatchId": "'+recid+'","SfBatchName": "JV-2053 |"}]}';
        HttpResponse resp = new HttpResponse();
        resp.setHeader('Content-Type','application/json');
        resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }
}