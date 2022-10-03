/**************************************************************************************************
* Name               : GenericHistoryComponentControllerTest                                      *
* Description        : This is a test class for GenericHistoryComponentController.                *
* Created Date       : 09/01/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date : 09/01/2017                                                                 *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE              COMMENTS                                              *
* 1.0         NSI         09/01/2017        Initial Draft                                         *
**************************************************************************************************/
@isTest(seeAllData = true)
private class GenericHistoryComponentControllerTest {
    
	private static testMethod void testHistoryComponent() {
		GenericHistoryComponentController controller = new GenericHistoryComponentController();
		String accountId;
		for(accounthistory thisHistory : [SELECT AccountId FROM accounthistory WHERE isDeleted = false LIMIT 1]){
	        accountId = thisHistory.AccountId;	       
		}
		if(String.isNotBlank(accountId)){
            controller.myObject = [SELECT Id FROM Account WHERE Id =: accountId];	
    		controller.getObjectHistory();
		}
	}
}// End of class.