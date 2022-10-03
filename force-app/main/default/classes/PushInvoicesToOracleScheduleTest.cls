@isTest
private class PushInvoicesToOracleScheduleTest{
    static testMethod void pushInvoicesTest1(){
    
        HexaBPM__SR_Status__c objSRStatus = new HexaBPM__SR_Status__c();
        objSRStatus.Name = 'Rejected';
        objSRStatus.HexaBPM__Code__c = 'REJECTED';
        objSRStatus.HexaBPM__Type__c = 'Rejected';
        insert objSRStatus;
    
        List<HexaBPM__Service_Request__c> newSRs = TestUtility.createSR(1,'Initial_Approval');
        newSRs[0].First_Name__c = 'Test First';
        newSRs[0].HexaBPM__Email__c = 'test@test.com';
        newSRs[0].HexaBPM__Send_SMS_to_Mobile__c = '+971564744747';
        newSRs[0].Company_Name__c = 'Test Company';
        newSRs[0].Biometric__c = 'No';
        newSRs[0].HexaBPM__Internal_SR_Status__c = objSRStatus.Id; 
        newSRs[0].HexaBPM__External_SR_Status__c = objSRStatus.Id;
        
        insert newSRs;
            
        test.startTest();
            PushInvoicesToOracleSchedule invoiceSched = new PushInvoicesToOracleSchedule ();
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, invoiceSched);
        test.stopTest();

    }
}