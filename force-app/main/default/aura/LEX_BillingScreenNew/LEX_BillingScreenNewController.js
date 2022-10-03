({
	init : function(component, event, helper) {
        var childCmp = component.find("BillingSearchComp");
        
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        //alert(recordId);
        if(recordId == undefined)
            recordId = 'Detail';
        //component.set("v.recordId", recordId);
        childCmp.passRecordId(recordId);
        
	},
     // After revisit the page
    onPageReferenceChanged: function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
})