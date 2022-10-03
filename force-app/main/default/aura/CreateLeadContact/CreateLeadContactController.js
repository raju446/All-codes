({
	doInit: function(component, event, helper) {
        // Create the action
        var action = component.get("c.getUserLead");
            action.setParams({
            "leadId": component.get("v.recordId")
        });
        // Add callback behavior for when response is received..
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                console.log('Dismissed');
                
                var userLead = response.getReturnValue();
                console.log(userLead);
                var createRecordEvent = $A.get("e.force:createRecord");
                var category;
                var nonfinancialProfileList = ['ADGM RA Business Development'];
                var financialProfileList = ['ADGM Financial Centre Development'];
                if(userLead && userLead.user){
                    var userInfo = userLead.user;
                    if(nonfinancialProfileList.indexOf(userInfo.Profile.Name) > -1)
                        category = 'Non Financial';
                    else if(financialProfileList.indexOf(userInfo.Profile.Name) > -1)
                        category = 'Financial';
                }
                var recordTypeId = $A.get("$Label.c.Lead_Contact_Record_Type_ID");
                createRecordEvent.setParams({
                    "entityApiName": "Lead",
                    "recordTypeId" : recordTypeId,
                    'defaultFieldValues': {
                        'Company':userLead.lead.Company,
                        'Related_Lead_Entity__c':userLead.lead.Id,
                        'Primary_Phone_Number_Country_Code_1__c':userLead.lead.Mobile_Country_Code__c,
                        'Primary_Phone_Number_1__c':userLead.lead.MobilePhone,
						'Lead_Street__c':userLead.lead.Lead_Street__c,
						'Lead_City__c':userLead.lead.Lead_City__c,
                        'Lead_Zip_Postal_Code__c':userLead.lead.Lead_Zip_Postal_Code__c,
						'State_Province__c':userLead.lead.State_Province__c,
                        'Lead_Country__c':userLead.lead.Lead_Country__c,
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