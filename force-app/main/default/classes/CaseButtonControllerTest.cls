@isTest
public with sharing class CaseButtonControllerTest {
    
    private static  List<Case> createdCaseList; 
    
    public static void init(){
        createdCaseList = TestClassUtility.createCase(
                                new List<Case>{
                                    new Case(Queue_Name__c ='Business Admin Team')}); 
    }
    
    public static testmethod void TestCaseButtonController(){
        init();
        String st = createdCaseList[0].Id;
        system.debug(st);
        system.debug(createdCaseList);
        CaseButtonController.releaseCaseToQueue(st); 
        CaseButtonController.AcceptCase(st);        
        
    } 
    
    
}