({
	showToast: function(component, event, helper, msg, type) {
    // Use \n for line breake in string
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      mode: "dismissible",
      message: msg,
      type: type
    });
    toastEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
  },
    
})