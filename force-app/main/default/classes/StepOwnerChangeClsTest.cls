@isTest
private class StepOwnerChangeClsTest{
    static testMethod void StepOwnerChangeClsTest1(){
    
    
        Group grp = new Group();
        grp.Name = 'Business Grp';
        grp.Type = 'Queue';
        insert grp;
        
        QueueSObject objque = new QueueSObject();
        objque.QueueId = grp.Id;
        objque.SObjectType = 'HexaBPM__Step__c';
        insert objque;
        
        User objUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Admin'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        
        insert objUser;
        
        GroupMember grpmember = new GroupMember();
        grpmember.GroupId = grp.Id;
        grpmember.UserOrGroupId = objUser.Id;
        insert grpmember;
    
        system.runAs(objUser){
    
            HexaBPM__SR_Steps__c createSRstep = new  HexaBPM__SR_Steps__c();
            insert createSRstep;
            
            List<Account> newAccounts = TestClassUtility.createAccounts(1);
            newAccounts[0].Oracle_Party_Id__c = '000001';
            newAccounts[0].Tax_Registration_Number__c = '123456';
            insert newAccounts; 
            
            List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Permit_Alcohol');
            createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
            insert createdSRList;

            List<HexaBPM__Step__c> createdstepList = TestUtility.createSteps(1,createdSRList[0].Id,createSRstep.Id);
            createdstepList[0].OwnerId = grp.Id;
            insert createdstepList; 

            test.startTest();
                StepOwnerChangeCls.AcceptStep(createdstepList[0].id, grp.Id);
                StepOwnerChangeCls.IsGroupMember(objUser.Id,grp.Id);
                StepOwnerChangeCls.ReleaseStep(createdstepList[0].id,objUser.Id,grp.Id);
            test.stopTest();
        }

    }
}