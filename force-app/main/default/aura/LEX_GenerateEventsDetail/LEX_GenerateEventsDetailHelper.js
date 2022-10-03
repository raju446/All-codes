({
	showTostMSG : function(component, event, helper, msg) {
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            "title": "Error!",
            "type" : "error",
            "message": msg
        });
        toastEvent.fire();
    }
})