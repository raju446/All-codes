@isTest
public class TestRestrictContactByName {
    public static testmethod void testName(){
    Contact con = new Contact(FirstName='raju', LastName='INVALIDNAME');
    insert con;
    }
}