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
     TurnTrue: function(component, event, helper) {
        console.log("its here") ;
        if(component.get('v.checkbox') == false) {
      component.set('v.checkbox', true);
        }else{
            component.set('v.checkbox', false);
            
        }
        console.log(component.get('v.checkbox')) ;
	},    
   
     escCase: function(component, event, helper) {
         
      helper.EscalateCaseReason(component, event, helper);
     
	},    
      

})