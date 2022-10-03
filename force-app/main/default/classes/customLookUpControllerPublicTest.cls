@isTest
public class customLookUpControllerPublicTest {
    
    static testMethod void testcustomLookUp(){
        
        list<Account> testAccount = TestClassUtility.createAccounts(1);
        insert testAccount;
        list<account> testList =  customLookUpControllerPublic.fetchLookUpValues('TestAccount','Name','Account','');
        
    }

}