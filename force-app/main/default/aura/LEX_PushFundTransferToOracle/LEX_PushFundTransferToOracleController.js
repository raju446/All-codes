/**
 * @File Name          : LEX_PushFundTransferToOracleController.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 6/30/2020, 3:00:22 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/29/2020   Jayanta Karmakar     Initial Version
**/
({
	init : function(component, event, helper) {
        /*var action1 = component.get("c.pushFundToOracle");
        action1.setParams({
            'sFundTransferId' : component.get("v.recordId")
        });
        action1.setCallback(this, $A.getCallback(function(response) {
            var response = response.getReturnValue();
            $A.get('e.force:refreshView').fire();
            console.log(response);
            if(response == 'Success'){
            	//helper.showToast('error', 'Error!', state);
                component.set("v.showSucess", true);
                component.set("v.sucessMessage", 'Record has been sucessfully push' );
                   
            }
        }));
        $A.enqueueAction(action1);
        */
        
       var v = component.get('v.recordId');
       console.log(v);
       component.set('v.Spinner',true);
       var action = component.get("c.getRecordDetail");
       action.setParams({
           'sFundTransferId': v
       });
       action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               console.log(JSON.stringify(response.getReturnValue()));
               var resp = response.getReturnValue();
               if(resp.Status__c != 'Success' && resp.Status__c != 'Approved'){
                   component.set('v.errorMessage','Status should be Success or Approved !');
                   component.set('v.showError',true);
                   component.set('v.Spinner',false);
               } else if(resp.Oracle_Response_Status__c == 'S'){
                   component.set('v.errorMessage','Record already pushed to Oracle !');
                   component.set('v.showError',true);
                   component.set('v.Spinner',false);
               } else {
                   var action2 = component.get("c.pushFundToOracle");
                   action2.setParams({
                       'sFundTransferId': v
                   });
                   action2.setCallback(this, function(response){
                       var state = response.getState();
                       component.set('v.Spinner',false);
                       if (state === "SUCCESS") {
                           var result2  = response.getReturnValue();
                           if(result2 == 'Success' || result2 == 'SUCCESS'){
                               component.set('v.sucessMessage','Record successfully pushed to Oracle !');
                               component.set('v.showSucess',true);
                           } else {
                               component.set('v.errorMessage',result2);
                               component.set('v.showError',true);
                           }
                       }
                   });
                   $A.enqueueAction(action2);
               }
           } else {
               component.set('v.Spinner',false);
               console.log("Failed with state: " + state);
           }
       });
       $A.enqueueAction(action);
		
	}
})