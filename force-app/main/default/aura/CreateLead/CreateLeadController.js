({
	doInit: function(component, event, helper) {
                // Create the action
                var action = component.get("c.getUserInfo");
                // Add callback behavior for when response is received..
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                        
                        var userInfo = response.getReturnValue();
                        console.log(userInfo);
                        var createRecordEvent = $A.get("e.force:createRecord");
                        var category;
                        var nonfinancialProfileList = ['ADGM RA Business Development'];
                        var financialProfileList = ['ADGM Financial Centre Development'];
                        if(userInfo){
                                if(nonfinancialProfileList.indexOf(userInfo.Profile.Name) > -1)
                                        category = 'Non Financial';
                                else if(financialProfileList.indexOf(userInfo.Profile.Name) > -1)
                                        category = 'Financial';
                        }
                        console.log('category'+category +' '+nonfinancialProfileList.indexOf(userInfo.Profile.Name) + ' ' +financialProfileList.indexOf(userInfo.Profile.Name))
                        var recordTypeId = $A.get("$Label.c.Lead_Entity_Record_Type_Id");
                        createRecordEvent.setParams({
                                "entityApiName": "Lead",
                                "recordTypeId" : recordTypeId,
                                'defaultFieldValues': {
                                        'Category__c':category
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