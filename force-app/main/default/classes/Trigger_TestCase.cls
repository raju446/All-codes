@isTest
    private class Trigger_TestCase{
        Account acc1 = new Account(Name='acc1', BillingCity ='Chennai', BillingCountry='india', BillingLatitude=5657.577, BillingLongitude=7845.46, BillingPostalCode='600075',BillingState='tamil nadu', BillingStreet='water well street');

    static testMethod void testAccountInsert() {
        Test.startTest();
        Test.stopTest();
        }

    }