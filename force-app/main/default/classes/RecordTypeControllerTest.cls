@isTest
public class RecordTypeControllerTest {
    
    public static testMethod void RecordTypeControllerTest(){
        Contact con=new Contact(
            FirstName='fname',
            LastName = 'lname',
            Email = 'email@test.com',
            Phone = '9743800309'); 
        insert con; 
        
        List<task> t = new List<task>{ new task(Description = 'desc',
                                                CRM_External_First_Name__c = 'test',
                                                CRM_External_Middle_Name__c = 'testl', 
                                                CRM_External_Last_Name__c = 'dadawd', 
                                                CRM_External_Contact_Id__c = con.id, 
                                                CRM_External_Email__c = 'teset@info.com',
                                                CRM_External_Company_Id__c = 'id002', 
                                                CRM_External_Mobile__c = '0987654321', 
                                                CRM_External_Country_Code__c = '+971', 
                                                CRM_External_Job_Title__c = 'CEO'
		)};

        insert t;  
        
        Test.startTest();
        List<String> recordTypeValues = RecordTypeController.fetchEntityRecordTypeValues();
        
        Id tmpRecordType = RecordTypeController.getEntityRecTypeId('ADGM Courts');

        List<String> contactRecordTypeValues = RecordTypeController.fetchContactRecordTypeValues();
        
        Id contactTmpRecordType = RecordTypeController.getContactRecTypeId('Contact - ADGM Court');
        RecordTypeController.RecordInfo campaignRecordTypeValues = RecordTypeController.fetchCampaignRecordTypeValues();
		RecordTypeController.DelegationInfo objDelegationInfo = RecordTypeController.getTaskDetails(t[0].id);        
        User currentUser = RecordTypeController.getUserInfo();
        
        //RecordTypeController.fetchCampaignRecordTypeValues();
        RecordTypeController.fetchCaseRecordTypeValues();
        
        Id tmpTestId =  RecordTypeController.getCaseRecTypeId('General Queries');
        Test.stopTest();
    }

}