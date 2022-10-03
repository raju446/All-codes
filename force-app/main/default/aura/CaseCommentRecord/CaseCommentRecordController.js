({
      doInit: function(component, event, helper) {
        // Fetch the case Commment list from the Apex controller
        helper.getCC(component, event, helper);
        
      },
   
      
      showComment: function(component, event, helper) {
          console.log('inside showComment');
          component.set("v.CaseCommentsSelected",'');
          helper.getHelper(component, event, helper);
          component.set("v.isOpen",true);
          
      },
    
     closeModel: function(component, event, helper) {
      // closes both the modal  
      component.set("v.isOpen", false);
      component.set("v.NewRecForm", false);
      console.log('HI');
      
   },
    
     closeModelButton: function(component, event, helper) {
      // closes both the modal  
      component.set("v.isOpen", false);
      component.set("v.NewRecForm", false);
      var a = component.get('c.doInit');
      $A.enqueueAction(a);
      $A.get('e.force:refreshView').fire();
   },

    
     
    createRecord: function(component, event, helper) {
       component.set("v.NewRecForm", true);
      
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
    
    createCaseComment: function(component, event, helper) {
        
      helper.newCaseComment(component, event, helper);
      
   },

    
    })