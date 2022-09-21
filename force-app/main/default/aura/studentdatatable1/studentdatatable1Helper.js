({
    getSupplierNetRecordsRecord : function( component ) {
        var action = component.get("c.getSupplierNetRecordsRecord");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = JSON.stringify(response.getReturnValue());
            if (component.isValid() && state === "SUCCESS")
                component.set("v.teacher2Lst", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
})