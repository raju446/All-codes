@isTest
private class SetupObjectDataHelperTest{
    static testMethod void SetupObjectDataHelperTest1(){
    
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

            test.startTest();
                SetupObjectDataHelper.getGroupData(grp.id);
                SetupObjectDataHelper.getsObjectQueues('HexaBPM__Step__c');
                SetupObjectDataHelper.getEmailTemplates();
                SetupObjectDataHelper.GetDelegatedUsers(objUser.Id);
            SetupObjectDataHelper.getGroupMembers(new List<String>{
                'Business Grp'});
            test.stopTest();
        }

    }
}