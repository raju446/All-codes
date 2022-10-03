@isTest
private class GLConfigurationControllerTest {
    
    @isTest static void testMethod1() {
        DateTime dt = Datetime.now();
        String curYear = String.ValueOf(Date.Today().Year());
        GL_Period_Configuration__c gp1 = new GL_Period_Configuration__c(Active__c=true, Month__c =dt.format('MMMM'), Year__c=curYear);
        insert gp1;
        GL_Period_Configuration__c gp2 = new GL_Period_Configuration__c(Active__c=true, Month__c ='January', Year__c='2021');
        insert gp2;
        
        test.startTest();
        
        GLConfigurationController.getGLPeriodDetails();
        GLConfigurationController.getExisitingGLConfiguration();
        GLConfigurationController.createNewGLPeriod('March','2021');
        GLConfigurationController.getPicklistValue('GL_Period_Configuration__c','Month__c');
        
        test.stoptest();  
        
    }
    
}