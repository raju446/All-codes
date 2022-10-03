@isTest
public class reUsableMultiSelectLookupCtrlTest {
    public static testmethod void test1(){
        List<Account> createdAccountList = TestClassUtility.createAccounts(2);
        insert createdAccountList;
        reUsableMultiSelectLookupCtrl.fetchLookUpValues(createdAccountList[0].Name, 'Account', new List<sObject>{createdAccountList[1]} ,'', 'id');
    }
}