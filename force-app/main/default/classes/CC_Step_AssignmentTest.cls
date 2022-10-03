@isTest
private class CC_Step_AssignmentTest{
    static testMethod void stepAssignmentTest(){
    
        test.startTest();
            CC_Step_Assignment stepAssgnment = new CC_Step_Assignment();
            stepAssgnment.Assign_Step_Owner_SR_Submit(null,null,null);
            stepAssgnment.Assign_Step_Owner_Step_Closure(null,null,null);
        test.stopTest();

    }
}