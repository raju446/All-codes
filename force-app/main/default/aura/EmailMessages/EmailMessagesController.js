({
      doInit: function(component, event, helper) {
        // Fetch the account list from the Apex controller
        helper.getEmailList(component, event, helper);
        $A.get('e.force:refreshView').fire();
      },
   
      
      getHelper: function(component, event, helper) {
          console.log('inside getHelper');
          var idx = event.target.id;
          console.log(idx);
          helper.MarkEmailUnread(component, event, helper);
          $A.get('e.force:refreshView').fire();
      },
    
      
    })