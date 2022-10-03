@isTest
public class StepTriggerTest
{

    public static testMethod void StepTrigger_UT()
    {
        List<HexaBPM__Service_Request__c> createdSRList; 
        HexaBPM__SR_Status__c srStatus = new HexaBPM__SR_Status__c();
        srStatus.HexaBPM__Code__c = 'SUBMITTED';
        insert srStatus;
        
        HexaBPM__Status__c status = new HexaBPM__Status__c(Name='Application Submitted',
        HexaBPM__Code__c='APPLICATION_SUBMITTED');
        insert status;
        
        HexaBPM__Status__c statusTC = new HexaBPM__Status__c(Name='Typing Completed',
        HexaBPM__Code__c='Typing_Completed');
        insert statusTC;
        
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].License_Expiry_Date__c = System.Today();
        createdAccountList[0].Oracle_Party_Id__c = '1234';
        insert createdAccountList;
        system.debug('======Aid=='+createdAccountList[0].id);

        
        Role__c objRole = new Role__c();
        objRole.Status__c  = 'Active';
        objRole.Type__c = 'Authorised Signatory';
        objRole.Subject_Account__c = createdAccountList[0].Id;
        insert objRole;
        
        system.debug('======Accid=='+objRole.Subject_Account__c);
        Business_Activity__c objBusAc = new Business_Activity__c();
        objBusAc.Entity__c = createdAccountList[0].Id;
        objBusAc.Activity_Code__c = '1234';
        insert objBusAc;
        
        Test.startTest();
            HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
            hst.HexaBPM__Active__c = true;
            hst.Name='Trainings and Seminars Permit';
            hst.HexaBPM__SR_RecordType_API_Name__c = 'Permit_Training_and_Seminar';
            insert hst;
            
            HexaBPM__SR_Template__c hst1 = new HexaBPM__SR_Template__c();
            hst1.HexaBPM__Active__c = true;
            hst1.Name='Initial Approval';
            hst1.HexaBPM__SR_RecordType_API_Name__c = 'Initial Approval';
            insert hst1;
        
            createdSRList = TestUtility.createSR(1,'Permit_Training_and_Seminar');
            createdSRList[0].HexaBPM__SR_Template__c = hst.id;
            createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].id;
            insert createdSRList;
            
            List<HexaBPM__Service_Request__c> createdSRList1 = TestUtility.createSR(1,'Initial_Approval');
            createdSRList1[0].HexaBPM__SR_Template__c = hst1.id;
            createdSRList1[0].HexaBPM__Customer__c = createdAccountList[0].id;
            insert createdSRList1;
            
            Amendment__c objAmm = new Amendment__c();
            objAmm.Full_Name__c = 'Test Participant 1';
            objAmm.Service_Request__c = createdSRList[0].Id;
            objAmm.Nationality_New__c = 'Australia';
            insert objAmm;
        
            HexaBPM__Step__c step = new HexaBPM__Step__c(HexaBPM__Summary__c='Test',HexaBPM__SR__c=createdSRList[0].id,
                HexaBPM__Status__c=statusTC.id);
            insert step;
            
            HexaBPM__Step__c step1 = new HexaBPM__Step__c(HexaBPM__Summary__c='Test',HexaBPM__SR__c=createdSRList1[0].id,
                HexaBPM__Status__c=status.id);
            insert step1;
            //HexaBPM__Step__c st = [Select HexaBPM__SR__r.Service_Request_Name__c FROM HexaBPM__Step__c where id=:step.id];
            //system.debug('===test=='+st.HexaBPM__SR__r.Service_Request_Name__c);
            try{
            update step;
            }catch(exception ex){}
            
            try{
            //step.HexaBPM__Status__c=statusTC.id;
            update step1;
            }catch(Exception e){}
            
             
            
            
            
        Test.stopTest();

    }
    
    public static testMethod void StepTrigger_UT1()
    {
        List<Account> createdAccountList = TestClassUtility.createAccounts(1);
        createdAccountList[0].License_Expiry_Date__c = System.Today();
        createdAccountList[0].Oracle_Party_Id__c = '1234';
        insert createdAccountList;
        
        List<HexaBPM__Service_Request__c> createdSRList; 
        HexaBPM__SR_Template__c hst = new HexaBPM__SR_Template__c();
            hst.HexaBPM__Active__c = true;
            hst.Name='Trainings and Seminars Permit';
            hst.HexaBPM__SR_RecordType_API_Name__c = 'Permit_Training_and_Seminar';
            insert hst; 
        createdSRList = TestUtility.createSR(1,'Permit_Training_and_Seminar');
        createdSRList[0].HexaBPM__SR_Template__c = hst.id;
        createdSRList[0].HexaBPM__Customer__c = createdAccountList[0].id;
        insert createdSRList;
       
        
        HexaBPM__Status__c stStatus = new HexaBPM__Status__c(Name='Approved',HexaBPM__Code__c='Approved');
        insert stStatus;
        
        HexaBPM__Step__c steps = new HexaBPM__Step__c(HexaBPM__Summary__c='Cancellation',HexaBPM__SR__c=createdSRList[0].id,
            HexaBPM__Status__c=stStatus.id);
        insert steps;
        try{
        update steps;
        }catch(exception e){}
    }
}