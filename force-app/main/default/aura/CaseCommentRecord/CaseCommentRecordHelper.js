({
getCC: function(component, event, helper) {
		var caseId = component.get("v.recordId");
        var action = component.get("c.getCaseCommentss");
    	action.setParams({
			CaseId : caseId
		});
    	action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
                
                var conts = response.getReturnValue();
                console.log(conts); 
                  
                component.set("v.wrapperList",conts);
              
          
			}
			else {
				console.log("Failed with state: " + state);
			}
		});
       
		$A.enqueueAction(action);
       
	},
    
    
     getHelper: function(component, event, helper) {
		var caseId = component.get("v.recordId");
		var GetCC = component.get("c.ShowComment"); // method in the apex class
        var idx = event.target.id;
        console.log (idx);
		GetCC.setParams({
			CaseId : caseId,
            emailID : idx
		});
        GetCC.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
                
                var casecomment = response.getReturnValue();
                console.log(casecomment); 
                  
                component.set("v.CaseCommentsSelected",casecomment);
                console.log(component.get("v.CaseCommentsSelected"));
                
          
			}
			else {
				console.log("Failed with state: " + state);
			}
		});
		$A.enqueueAction(GetCC);
        
	},
    
     newCaseComment: function(component, event, helper) {
       var caseId = component.get("v.recordId");
       var body = component.get("v.NewCommentBody");
       var ispublic = component.get("v.checkbox");
       console.log(body);
       if(body !=null && body !=''){
           var NewCC  = component.get("c.CreateCaseComment");
           NewCC.setParams({
               CaseId      : caseId,
               CommentBody : body,
               IsPublic    : ispublic
            });
            NewCC.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    console.log(state);   
                    component.set("v.NewRecForm", false);
                    component.set("v.NewCommentBody", '');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message: 'Case comment was created',
                        messageTemplate: 'Record {0} created! See it {1}!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                   
                }
                else {
                    console.log("Failed with state: " + state);
                }
            });
           $A.enqueueAction(NewCC);
           var aa = component.get('c.doInit');
           $A.enqueueAction(aa);
           $A.get('e.force:refreshView').fire();
       }
         
   },
    
})