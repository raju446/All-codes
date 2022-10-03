public class GLConfigurationController {
    
    @AuraEnabled
    public static GLPeriodWrapper getGLPeriodDetails(){
        GLPeriodWrapper wrapper = new GLPeriodWrapper();
        wrapper.availableMonths = getPicklistValue('GL_Period_Configuration__c', 'Month__c');
        wrapper.availableYears = getPicklistValue('GL_Period_Configuration__c', 'Year__c');
        wrapper.exisitingGLConfigList = getExisitingGLConfiguration();
        DateTime dt = Datetime.now();
        wrapper.selectedMonth = dt.format('MMMM');
        wrapper.selectedyear = dt.format('YYYY');
        return wrapper;
    }
    
    public static List<GL_Period_Configuration__c> getExisitingGLConfiguration(){
        return [SELECT Id, Month__c, Year__c, Active__c FROM GL_Period_Configuration__c WHERE Active__c = true];
    }
    
    public static List<String> getPicklistValue(String objectName, String fieldName){
        List<String> picklistValues = new List<String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistValues.add(String.valueOf(pickListVal.getValue()));
        }
        return picklistValues;
    }
    
    @AuraEnabled
    public static void deleteGLPeriod(String glPeriodId){
        DELETE [SELECT Id FROM GL_Period_Configuration__c WHERE Id =: glPeriodId];
    }
    
    @AuraEnabled
    public static string createNewGLPeriod(String selectedMonth, String selectedYear){
        List<GL_Period_Configuration__c> confiLst = [SELECT Id FROM GL_Period_Configuration__c WHERE Month__c = :selectedMonth AND Year__c = :selectedYear];
        if(!confiLst.isEmpty()){
            return 'GL Period already available.';
        }else{
        	INSERT new GL_Period_Configuration__c(Month__c = selectedMonth, Year__c = selectedYear, Active__c = true);
            return 'GL Period added';
        }
        
    }
    
    public class GLPeriodWrapper{
        @AuraEnabled
        public List<String> availableMonths;
        @AuraEnabled
        public List<String> availableYears;
        @AuraEnabled
        public String selectedMonth;
        @AuraEnabled
        public String selectedYear;
        @AuraEnabled
        public List<GL_Period_Configuration__c> exisitingGLConfigList;
    }
}