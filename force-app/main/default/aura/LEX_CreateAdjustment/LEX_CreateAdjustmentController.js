({
	doInit : function(component, event, helper) {
        component.set("v.isOpen", true);
        console.log('Hey here ');
        var action = component.get("c.getDefaultValues");
        action.setParams({
            'invoiceId' : component.get("v.recordId")
        });        
        action.setCallback(this, function(response) {
            console.log('response.getState() '+response.getState());
			if (response.getState() == "SUCCESS") {
            	var Authority = response.getReturnValue();
                console.log('Authority '+Authority);
                if(Authority != 'Not synced'){
                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": 'Invoice_Line_Item__c',
                        "recordTypeId": $A.get("$Label.c.Adjustment_Record_Type"),
                        "defaultFieldValues": {
                            'Invoice__c' : component.get("v.recordId"),
                            'Operating_Unit__c' : Authority
                        }
                    });
                    createRecordEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
        
	}
})