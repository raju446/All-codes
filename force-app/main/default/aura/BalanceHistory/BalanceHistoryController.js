({
	doInit : function(component, event, helper) {
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
    	component.set('v.selectedGLDate', today);
        
		/*var action = component.get("c.getOperatingUnits");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var options = [];
                var response = response.getReturnValue();
                for(var i = 0; i < response.length; i++){
                    var option = {};
                    option.value = response[i];
                    option.label = response[i];
                    options.push(option);
                }
                component.set("v.options", options);
                
            }
        });
        $A.enqueueAction(action);*/
	},
    handleSubmit: function (component, event){
        component.set('v.disableSubmit', true);
        var glDateValue = component.get('v.selectedGLDate');
        
        var action = component.get("c.createInvoiceReceiptRecords");
        action.setParams({ glDate : glDateValue });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                //alert(response);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": response,
                    duration: '2000'
                });
                toastEvent.fire();
                
            }
        });
        $A.enqueueAction(action);
    },
    handleChange: function (component, event) {
        //Get the string of the "value" attribute on the selected option
        var selectedValue = event.getParam("value");
        component.set('v.selectedOperatingUnit', selectedValue);
        //alert("Selected Option: '" + selectedValue + "'");
    }
})