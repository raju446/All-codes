({
   
   
    doInit: function(component, event, helper) {
        
      // for Display Model,set the "isOpen" attribute to "true"
      helper.getHasAccsess(component, event, helper);
   
	},

   closeAction:function (component, event, helper) {
		//Close the popup
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
		dismissActionPanel.fire();
		$A.get('e.force:refreshView').fire();
	},
     
     getHelper: function(component, event, helper) {
         
      helper.getapexmethod(component, event, helper);
     
	},    
      

})