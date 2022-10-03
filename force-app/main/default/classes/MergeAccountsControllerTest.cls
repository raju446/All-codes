/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class MergeAccountsControllerTest {
   /* public static testmethod void validateResult() {
        Test.startTest(); 
        List<Account> createdAccountList = new List<Account>();
        Integer count = 0;
        for(Account objAcc : TestClassUtility.createAccounts(100)) {
            objAcc.Website = 'www.ADGM.com';
            objAcc.Source_System_Id__c = 'test Data' + count;
            count++;
            createdAccountList.add(objAcc);
        }        
        
        insert createdAccountList;
        List<Account> masterAccountList = TestClassUtility.createAccounts(1);
        insert masterAccountList;
        
        //List<Duplicate_Key__c> createdDuplicateKeyList = TestClassUtility.createDuplicateKey(100, createdAccountList);
        //insert createdDuplicateKeyList;
        List<Account> currentAccountDetail = MergeAccountsController.getCurrentAccount(createdAccountList[0].id);
        List<MergeAccountsController.EntityWrapper> enWrapperLst = new List<MergeAccountsController.EntityWrapper>();
        for(Account accRec : currentAccountDetail){
            MergeAccountsController.EntityWrapper enWrapperObj = new MergeAccountsController.EntityWrapper();
            enWrapperObj.accountRec = accRec;
            enWrapperObj.isSelected = false;
            enWrapperLst.add(enWrapperObj);
        } 
        List<MergeAccountsController.EntityWrapper> searchResult = MergeAccountsController.getSearchResult(createdAccountList[0].id, enWrapperLst, 'Test', '','','');
        List<MergeAccountsController.EntityWrapper> searchResult1 = MergeAccountsController.getSearchResult(createdAccountList[0].id, enWrapperLst, 'Test', 'test','test','test');
        List<MergeAccountsController.EntityWrapper> duplicateAccounts = MergeAccountsController.getDuplicateAccounts(createdAccountList[0].id);
        List<Account> duplicateAccList = new List<Account>();
        for(MergeAccountsController.EntityWrapper wrapObj : duplicateAccounts){
            duplicateAccList.add(wrapObj.accountRec);
        }
        system.debug(duplicateAccList.size());
        String mergeResult = MergeAccountsController.mergeEntities(masterAccountList[0], duplicateAccList);
        
        //MergeAccountsController.removeDuplicate(createdAccountList[0],createdDuplicateKeyList);
        //MergeAccountsController.removeDuplicate(createdAccountList[0],null);
        Test.stopTest();
    }//end validateResult */
    
    @isTest static void testMethod1() {
		Account[] acc = TestClassUtility.createAccounts(20);
        acc[0].Oracle_Party_Id__c = '123';
		acc[0].Source_System_Name__c = 'FSRA';
        acc[0].website = 'www.google.com';
        acc[0].Source_System_Id__c = '1234ASD';
		
		acc[1].Oracle_Party_Id__c = '1234';
        acc[1].Source_System_Name__c = 'FSRA';
		insert acc;
		
		
		MergeAccountsController.getCurrentAccount(acc[0].Id);
		MergeAccountsController.getSearchResult(acc[0].Id, null,'TestAccount','','','','');
        MergeAccountsController.getDuplicateAccounts(acc[0].Id);
        MergeAccountsController.mergeEntities(acc[0],acc);
        MergeAccountsController.getDuplicateEntityDetails(acc[0].Id);
        
        MergeAccountsController.getSearchResult(acc[0].Id, null,'TestAccount','test@test.com','0987655','test','');
	}
}