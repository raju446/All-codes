//({
   // fetchAccHelper : function(component, event, helper) {
       // var action = component.get("c.createCon");
      //  component.set('v.mycolumns', [
      //      {label: 'Opportunity Name', fieldName: 'Name', type: 'text'},
       //         {label: 'Close Date', fieldName: 'CloseDate', type: 'text'},
       //         {label: 'Stage Name', fieldName: 'StageName', type: 'Picklist'}
       //     ]);
//        var action = component.get("c.fetchAccounts");//
//        var actId = component.get("v.recordId");
   //     action.setParams({ "actId":actId
    //    });
    //    action.setCallback(this, function(response){
        //    var state = response.getState();
       //     if (state === "SUCCESS") {
       //         component.set("v.acctList", response.getReturnValue());
       //     }
       // });
   //     $A.enqueueAction(action);
   // },
   
	//helperMethod : function() {
		
	//}

//})
  ({
	 // Fetch the Opportunity from the Apex controller
      accList: function(component, event, helper) {
        var action = component.get('c.fetchAccounts');          
        action.setCallback(this, function(response){
            var state = response.getState();      
            //alert('state ' + state);
            if(state == "SUCCESS"){
                var result = response.getReturnValue();
                //alert('result ' + JSON.stringify(result));                
                component.set('v.opportunity',result);
            }
        });
        $A.enqueueAction(action);
      }
    
})