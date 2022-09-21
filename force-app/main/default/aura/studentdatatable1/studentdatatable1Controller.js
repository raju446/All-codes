({
    doInit : function(component, event, helper) {
        var action = component.get("c.getteacher2Records");
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            console.log("teachers2... "+JSON.stringify(response.getReturnValue()));
            if (component.isValid() && state === "SUCCESS")
                component.set("v.teachers2", response.getReturnValue());  
        });
        $A.enqueueAction(action);
    },

    Clicked : function(component, event, helper){
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        console.log(id_str);

        var action = component.get("c.getstudent2Records");
        action.setParams({ teacher2Id :  id_str});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("students2sss... "+JSON.stringify(response.getReturnValue()));
            if (component.isValid() && state === "SUCCESS")
                component.set("v.students2", response.getReturnValue()); 
        });
        $A.enqueueAction(action);
    }
})