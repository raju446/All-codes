({      
    getstudents2List: function(component) {
        var action = component.get('c.getstudent2');
        var self = this;
        action.setCallback(this, function(actionResult) {
            component.set('v.student2', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})