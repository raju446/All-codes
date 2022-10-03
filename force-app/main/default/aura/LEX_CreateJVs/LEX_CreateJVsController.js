({
	init : function(component, event, helper) {
        var v = component.get('v.recordId');
        console.log(v);
		component.set('v.Spinner',true);
		var action = component.get("c.fetchRecordDetails");
        action.setParams({
            'recId': v
        });
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                var resp = response.getReturnValue();
                if(resp.Status != 'Success' && resp.Status != 'Approved'){
                    component.set('v.errorMessage','Status should be Success or Approved !');
                    component.set('v.showError',true);
                    component.set('v.Spinner',false);
				} else if(resp.isJournalAlreadyCreated){
					component.set('v.errorMessage','Journal already created !');
                    component.set('v.showError',true);
                    component.set('v.Spinner',false);
				} else {
                    var action2 = component.get("c.createJournalEntries");
                    action2.setParams({
                        'recordId': v,
                        'objectType' : resp.objType
                    });
                    action2.setCallback(this, function(response){
                        var state = response.getState();
                        component.set('v.Spinner',false);
                        if (state === "SUCCESS") {
                            var result2  = response.getReturnValue();
                            if(result2 == 'Success' || result2 == 'SUCCESS'){
                                component.set('v.sucessMessage','Journal records created !');
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