({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Name', fieldName:'Name',sortable:true,type:'text', initialWidth: 200},
            {label: 'Date Time', fieldName:'WhatsAppDate__c',sortable:true,type:'text', initialWidth: 300},
            {label: 'Chat', fieldName:'WhatsAppText__c',sortable:true,type:'text', initialWidth: 400}
        ]);
        helper.getChats(component, helper);
        helper.getChatsCount(component, helper);
    },
   
    onFirst: function(component, event, helper) {
        var totalPages = component.get("v.totalPages");
        component.set("v.isLastPage", false);
        component.set("v.pageNumber", 1);
        helper.getChats(component, helper);     
    },
    onPrev: function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        var totalPages = component.get("v.totalPages");
        if(pageNumber <= totalPages){
            component.set("v.isLastPage", false);
            component.set("v.pageNumber", pageNumber-1);
            helper.getChats(component, helper);     
        } 
    },
    onNext: function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        var totalPages = component.get("v.totalPages");
        if(totalPages > pageNumber){
            component.set("v.pageNumber", pageNumber+1);
            helper.getChats(component, helper);
            if(pageNumber==(totalPages-1)){
                component.set("v.isLastPage", true); 
            }
        }
    },
    onLast: function(component, event, helper) {
        var lastPage = component.get("v.totalPages");
        component.set("v.isLastPage", true); 
        component.set("v.pageNumber", lastPage);
        helper.getChats(component, helper);
    },
    
})