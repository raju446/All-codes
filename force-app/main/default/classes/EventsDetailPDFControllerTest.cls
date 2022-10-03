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
public class EventsDetailPDFControllerTest {
    static testMethod void EventsDetailTest() {
        // create Campaign
        List<Campaign> listCampaigns = TestClassUtility.createCampaigns(1);
        listCampaigns[0].CRM_Meeting_Date_Time__c = system.Now();
         listCampaigns[0].CRM_End_Date__c = DateTime.now().addDays(6);
        insert listCampaigns;
        Test.startTest();
        PageReference myVfPage = Page.EventsDetailPDF;
        Test.setCurrentPage(myVfPage);
        // Put the current page Parameters
		ApexPages.currentPage().getParameters().put('fromDate',string.valueOf(system.Now()));
		ApexPages.currentPage().getParameters().put('toDate',string.valueOf(system.Now()));
        EventsDetailPDFController objEventsDetailPDFController = new EventsDetailPDFController();
        objEventsDetailPDFController.fetchEvents();
        Test.stopTest();
    }
}