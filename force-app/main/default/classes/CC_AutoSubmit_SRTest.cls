@isTest
public with sharing class CC_AutoSubmit_SRTest {
	
	private static HexaBPM__SR_Status__c Srstatus;
	private static List<HexaBPM__Service_Request__c> createdSRList; 
	
	private static void init(){
		Srstatus = new HexaBPM__SR_Status__c();
		Srstatus.Name = 'test';
		Srstatus.SR_Approved__c = true;
		Srstatus.HexaBPM__Code__c = '123';
		Srstatus.HexaBPM__Type__c = 'End';
		insert Srstatus;
		
		createdSRList = TestUtility.createSR(1,'Initial_Approval');
        insert createdSRList;
	}
	
	public static testmethod void TestCC_AutoSubmit_SR(){
        init();
        Set<Id> s1 = new Set<Id>();
        s1.add(createdSRList[0].Id);
        String str = Srstatus.Id;
        CC_AutoSubmit_SR con = new CC_AutoSubmit_SR();
        //List<HexaBPM__Step__c> lstOfSteps = [SELECT Id, HexaBPM__SR__r.HexaBPM__Customer__c FROM HexaBPM__Step__c WHERE Id = :createdstepList[0].Id];
        con.AutoSubmit_SR(s1,str);
    }
	
}