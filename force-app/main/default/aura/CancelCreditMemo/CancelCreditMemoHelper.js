({
	showToast: function(type, title, message, toastMode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message,
            "mode" : toastMode
        });
        toastEvent.fire(); 
    }

})