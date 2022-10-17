({
    getChats : function(component, helper) {
        var action = component.get("c.getChatsList");
        action.setParams({
            "pageSize" : component.get("v.pageSize").toString(),
            "pageNumber" : component.get("v.pageNumber").toString(),
            "conId" :  component.get("v.recordId").toString()
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var data;
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.recordList", result);
            }
        });
        $A.enqueueAction(action);
    },
    getChatsCount: function(component, helper) {
        const action = component.get("c.getChatsCount");
        // Register the callback function
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                var pageSize=component.get("v.pageSize");
                component.set("v.totalRecords", result)
                var totalPages = Math.ceil(result/pageSize);
                component.set("v.totalPages",totalPages);
            }
        });
        $A.enqueueAction(action);
    },
    
})