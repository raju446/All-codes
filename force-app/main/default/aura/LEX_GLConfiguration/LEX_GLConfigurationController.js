({
	doInit : function(component, event, helper) {
		helper.initMethod(component, event, helper);
	},
    configurePeriod : function(component, event, helper){
        console.log(component.get('v.selectedYear'));
        console.log(component.get('v.selectedMonth'));
        helper.configureNewPeriod(component, event, helper);
    },
    closePeriod : function(component, event, helper){
        helper.closePeriod(component, event, helper);
        
    }
})