<!--Create contact and title field on Opportunity Contact roles Object and add fields apex and js component-->
({
 myAction : function(component, event, helper) 
     {
  component.set('v.columns', [
            {label: 'Contact', fieldName: 'Contact__c', type: 'Lockup'},
            {label: 'Role', fieldName: 'Role', type: 'Picklist'},
            {label: 'Title', fieldName: 'Title__c', type: 'text'},
         ]);

var ConList = component.get("c.getRelatedList");
   ConList.setParams
         ({
             recordId: component.get("v.recordId")
         });
   
 ConList.setCallback(this, function(data) 
                           {
             component.set("v.ContactRole", data.getReturnValue());
                           });

         $A.enqueueAction(ConList);
 }
})
