({
	init : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var url = '/apex/CustomerOpenBalanceLetterPage?id=' + recordId;
        window.open(url, '_blank');
        
	},
    doneRendering: function (component, helper) {
        window.setTimeout(
            $A.getCallback(function () {
                $A.get("e.force:closeQuickAction").fire();
            }), 500
        );
    }

})