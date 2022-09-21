({
	packItem : function(component, event, helper) {
		component.set("v.item.packed__c",true);
        event.getsource().set("v.desable",true);
	}
})