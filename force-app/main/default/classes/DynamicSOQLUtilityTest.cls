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
public class DynamicSOQLUtilityTest {
    public static testmethod void doTest() {
        String soqlQuery = '';
        List<String> listFieldAPINames = new List<String>();
        listFieldAPINames.add('Id');
        listFieldAPINames.add('Survey_Category__c');
        DynamicSOQLUtility dynamicSOQLUtility = new DynamicSOQLUtility();
        soqlQuery = dynamicSOQLUtility.createSelect(listFieldAPINames , 'CRM_Survey_Question__c');
        soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Survey_Category__c', 'null', '<>');
        soqlQuery = dynamicSOQLUtility.addWhereMultiCondition(soqlQuery, 'Survey_Category__c', new Set<String>{'Test'}, 'INCLUDES', 'AND');
        soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'Question_Type__c', 'Text', '<>', 'AND');
        soqlQuery = dynamicSOQLUtility.addLimitCondition(soqlQuery, 4);
        
        soqlQuery = '';
        listFieldAPINames = new List<String>();
        listFieldAPINames.add('Id');
        listFieldAPINames.add('CRM_ADGM_Internal_Feedback__c');
        dynamicSOQLUtility = new DynamicSOQLUtility();
        soqlQuery = dynamicSOQLUtility.createSelect(listFieldAPINames , 'Campaign');
        soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'CRM_Approval_Status__c', 'null', '<>');
        soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'CRM_ADGM_Internal_Feedback__c', true, '<>', 'AND');
        soqlQuery = dynamicSOQLUtility.addWhereCondition(soqlQuery, 'CRM_Approval_Status__c', new List<String>{'Under Review'}, '<>', 'AND');
    }
}