({
	nextProcess : function(component, event, helper) {
        var selectedToDate = component.get("v.toDate");
        var selectedFromDate = component.get("v.fromDate");
        if(selectedToDate == null || selectedToDate == '' || selectedFromDate == null || selectedFromDate == '') {
            helper.showTostMSG(component, event, helper, 'Please enter the date range to generate the events details.');
        } else if(selectedToDate <  selectedFromDate) {
            helper.showTostMSG(component, event, helper, 'From Date should be greater than To Date');
        } else {
            var url = '/apex/EventsDetailPDF?fromDate='+selectedFromDate+'&toDate='+selectedToDate;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": url
            });
            urlEvent.fire();
        }
		 
	}
})