({
	doInit: function(component, event, helper) {
        // Create the action
        var action = component.get("c.getCaseInfo");
            action.setParams({
           	 "id": component.get("v.recordId")
        	});
        // Add callback behavior for when response is received..
        action.setCallback(this, function(response) {
			console.log(response);
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                console.log('Dismissed');
                
                var caseRec = response.getReturnValue();
				console.log(caseRec);
				var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Lead",
                    "recordTypeId" : caseRec.recordTypeId,
                    'defaultFieldValues': {
                        'FirstName':caseRec.caseObj.CRM_First_Name__c,
						'LastName':caseRec.caseObj.CRM_Last_Name__c,
						'Email':caseRec.caseObj.Email_Address__c,
                        'MobilePhone':caseRec.caseObj.CRM_Mobile__c ,
                        'Phone':caseRec.caseObj.CRM_Phone__c,
                        'Company': caseRec.caseObj.CRM_Company__c,
						'Case__c':component.get("v.recordId")
                        
                    }
                });
                createRecordEvent.fire();
            }
            else {
                console.log("Failed with state: " + state);
            }
        });

        // Send action off to be executed
        $A.enqueueAction(action);
        
    }
})