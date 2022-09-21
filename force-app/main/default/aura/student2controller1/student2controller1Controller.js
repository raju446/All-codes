({
    doInit: function(component, event, helper) {
        helper.getstudents2List(component);
    },
    searchKeyChange: function(component, event) {
        var searchKey = component.find("searchKey").get("v.value");
        console.log('searchKey:::::'+searchKey);
        var action = component.get("c.findByname");
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(a) {
            component.set("v.student2", a.getReturnValue());
        });
        $A.enqueueAction(action);
    }   
})