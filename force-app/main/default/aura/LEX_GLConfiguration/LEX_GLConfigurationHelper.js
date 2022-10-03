({
	initMethod : function(component, event, helper) {
        var action = component.get('c.getGLPeriodDetails');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " , response.getReturnValue());
                component.set("v.glPeriodWrapper", response.getReturnValue());
                component.set('v.selectedYear', response.getReturnValue().selectedYear);
        		component.set('v.selectedMonth',response.getReturnValue().selectedMonth);
                
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    closePeriod : function(component, event, helper){
        var ctarget = event.currentTarget;
        var indx = ctarget.dataset.value;
        console.log(indx);
        
        var glConfigWrap = component.get("v.glPeriodWrapper");
        console.log('glConfigWrap==>>', glConfigWrap.exisitingGLConfigList[indx].Id);
        
        var action = component.get('c.deleteGLPeriod');
        action.setParams({ glPeriodId : glConfigWrap.exisitingGLConfigList[indx].Id });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = 'GL Period Closed successfully.';
                //alert(response);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": response,
                    duration: '1000'
                });
                toastEvent.fire();
                
                //alert('GL Period Closed successfully.');
                helper.initMethod(component, event, helper);
            }
        });
        $A.enqueueAction(action);
        
    },
    configureNewPeriod : function(component, event, helper){
        var action = component.get('c.createNewGLPeriod');
        action.setParams({ selectedMonth : component.get('v.selectedMonth'), selectedYear : component.get('v.selectedYear') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                //alert(response);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": response,
                    duration: '1000'
                });
                toastEvent.fire();
                
                //alert(response);
                helper.initMethod(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    }
})