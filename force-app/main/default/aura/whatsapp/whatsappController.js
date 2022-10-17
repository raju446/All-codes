({
	doInit : function(component, event, helper) {
        var action = component.get("c.fetchContact");
         action.setParams({
            "conId" : component.get("v.recordId").toString()
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var data;
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.con", result);
            }
        });
        $A.enqueueAction(action);
	},
    sendWhatsApp : function(component, event, helper){
        var action = component.get("c.saveChat");
         action.setParams({
            "conId" : component.get("v.recordId").toString(),
             "chat" : component.find("myText").get("v.value")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var data;
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
            }
        });
        $A.enqueueAction(action);

        
        var contact = component.get("v.con");
        var msg = component.find("myText").get("v.value");
        var url= "https://wa.me/91"+contact.MobilePhone+"?text="+msg;
        window.open(url, '_blank');
        $A.get("e.force:closeQuickAction").fire();
    }
    
})