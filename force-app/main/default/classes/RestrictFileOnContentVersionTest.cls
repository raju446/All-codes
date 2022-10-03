@isTest
public class RestrictFileOnContentVersionTest {
    static testMethod void validateRestrictFileOnContentVersion() {
        Trigger_Settings__c TS = new Trigger_Settings__c();
        TS.Name = 'RestrictFileOnContentVersionTrigger';
        TS.Is_Active__c = true;
        insert TS;
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        ContentVersion contentVersion = new ContentVersion(Title = 'Penguins',PathOnClient = 'Penguins.exe',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        try{
            insert contentVersion; 
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('cannot upload') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
}