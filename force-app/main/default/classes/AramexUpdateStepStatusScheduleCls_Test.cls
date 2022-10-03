@isTest
private class AramexUpdateStepStatusScheduleCls_Test {
    
    @isTest static void test_method_one() {
        Integer addTime =30;
        DateTime now =  System.now().addMinutes(addTime);
        String day = string.valueOf(now.day());
        String month = string.valueOf(now.month());
        String hour = string.valueOf(now.hour());
        String minute = string.valueOf(now.minute());
        String second = string.valueOf(now.second());
        String year = string.valueOf(now.year());

        String strJobName = 'ARAMEX-STEP_CLOURE_JOB : ' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        
        Test.startTest();
            System.schedule(strJobName, strSchedule, new AramexUpdateStepStatusScheduleCls());
           //AramexUpdateStepStatusScheduleCls obj = new AramexUpdateStepStatusScheduleCls();
           //obj.execute(Null);
            
        Test.stopTest();
    }
    
    @isTest static void test_method_two() {
        // Implement test code
    }
    
}