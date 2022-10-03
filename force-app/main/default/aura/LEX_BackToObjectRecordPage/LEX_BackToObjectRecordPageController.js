({
	doInit : function(component, event, helper) {
		console.log('im heer');
        var recId = component.get("v.recordId");
         var action = component.get("c.fetchRelatedObject");
    var requestWrap = {
      parentRecId: recId
    };
    action.setParams({
      requestWrapParam: JSON.stringify(requestWrap)
    });

    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        var respWrap = response.getReturnValue();
          if(respWrap.relatedRecId != null){
              window.open('/lightning/r/Case/' + respWrap.relatedRecId  + '/view','_self');
          }else{
             helper.showToast(component, event, helper, 'No related case found', 'error'); 
          }
        
      
      } else {
        console.log("@@@@@ Error " + response.getError()[0].message);
          helper.showToast(component, event, helper, response.getError()[0].message, 'error') 
      }
    });
    $A.enqueueAction(action);
  },
    
    
        
	
})