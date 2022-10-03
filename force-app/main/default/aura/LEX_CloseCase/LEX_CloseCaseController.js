({
    
    
    doInit: function(component, event, helper) {
        
        helper.getHasAccsess(component, event, helper);
        helper.getQucikText(component, event, helper);
    },
    
    closeAction:function (component, event, helper) {
        //Close the popup
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    },
    
    getHelper: function(component, event, helper) {
        var inputCmp1 = component.find("resolutionValue");
        var resVal = component.get("v.caseResolution");
        if(resVal.trim() == ''){
            $A.util.addClass(inputCmp1, 'errorFld');
        } else {
            $A.util.removeClass(inputCmp1, 'errorFld');
        }
         
        helper.getapexmethod(component, event, helper);
        
    },    
    
    
})