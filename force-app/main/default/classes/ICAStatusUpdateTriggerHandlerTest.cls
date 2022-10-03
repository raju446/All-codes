@isTest
public class ICAStatusUpdateTriggerHandlerTest
{
    private static testMethod void ICAStatusUpdateTriggerHandlerUT()
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].Tax_Registration_Number__c = '123456';
        insert newAccounts; 
        
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
        hst.HexaBPM__Active__c = true;
        hst.Name='Initial_Approval';
        hst.HexaBPM__SR_RecordType_API_Name__c = 'Initial_Approval';
        insert hst;
        
        HexaBPM__Status__c stepStatus = new HexaBPM__Status__c(Name='Awaiting Signatory Details Update',HexaBPM__Type__c='Start',HexaBPM__Code__c='AWAITING_SIGNATORY_DETAILS_UPDATE');
        insert stepStatus;
        HexaBPM__Status__c stepStatus1 = new HexaBPM__Status__c(Name='Awaiting Initial Approval Copy download',HexaBPM__Type__c='Start',HexaBPM__Code__c='AWAITING_INITIAL_APPROVAL_COPY_DOWNLOAD');
        insert stepStatus1;
        
        HexaBPM__Step_Template__c stepTemplate1 = new HexaBPM__Step_Template__c(Name='Download Initial Approval Copy',HexaBPM__Code__c='Download Initial Approval Copy',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Download Initial Approval Copy');
        insert stepTemplate1;
        HexaBPM__Step_Template__c stepTemplate = new HexaBPM__Step_Template__c(Name='Update Signatory Details',HexaBPM__Code__c='Update Signatory Details',HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Summary__c='Update Signatory Details');
        insert stepTemplate;
        
        HexaBPM__SR_Steps__c srSteps = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate.id,
            HexaBPM__Start_Status__c=stepStatus.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Signatory Details Update',
            HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps;
        
        HexaBPM__SR_Steps__c srSteps1 = new HexaBPM__SR_Steps__c(HexaBPM__SR_Template__c=hst.id,HexaBPM__Step_Template__c=stepTemplate1.id,
            HexaBPM__Start_Status__c=stepStatus1.id,HexaBPM__Active__c=true,HexaBPM__Summary__c='Download Copy',
            HexaBPM__Step_RecordType_API_Name__c='General',HexaBPM__Step_Type__c='Quick Action',HexaBPM__Group_Name__c='Verification of Application');
        insert srSteps1;
        
        test.startTest();
            List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR1(1,'Initial_Approval','56565');
            createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
            createdSRList[0].HexaBPM__SR_Template__c = hst.id;
            insert createdSRList;
        
            ICA_StatusUpdateQueue que = new ICA_StatusUpdateQueue('1',createdSRList[0].Id);
            system.enqueuejob(que);
            
            ICA_StatusUpdateQueue que1 = new ICA_StatusUpdateQueue('2',createdSRList[0].Id);
            system.enqueuejob(que1);
            
            ICA_DownloadIACopyQueue que3 = new ICA_DownloadIACopyQueue(createdSRList[0].Id);
            system.enqueuejob(que3);
           // ICAStatusUpdate__e ev1 = new ICAStatusUpdate__e(RecordId__c=createdSRList[0].Id,Status__c='1');
            //EventBus.publish(ev1);
            
           // ICAStatusUpdate__e ev2 = new ICAStatusUpdate__e(RecordId__c=createdSRList[0].Id,Status__c='2');
            //EventBus.publish(ev2);
        test.stopTest();
    }
}