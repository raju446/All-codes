({
	parentEventAction : function(component, event, helper) {         
        var cmpMsg = event.getParam("cmpMsg"); 
        var popFadeEvnt = event.getParam("popFadeEvnt");  
        //alert('cmpMsg ' + cmpMsg + 'popFadeEvnt ' + popFadeEvnt);
        component.set("v.modalFade", popFadeEvnt);
  },
    
    cancelPopup:function(component, event, helper){        
        component.set("v.modalFade",'slds-hide');
 },
     submitfunction : function(component, event, helper) {
        var lee = component.get('v.lea');
        var a = component.get('c.createLead');
        a.setParams({'le':lee});
        a.setCallback(this,function(r){
            component.set('v.lea',r.getReturnValue());
      });
         $A.enqueueAction(a);
  },  
     showToast : function(component, event, helper) {
        component.find('notifyId').showToast({
            "variant": "Success",
            "title": "Success!",
            "message": "Component Loaded successfully."
      });
  }
  
})