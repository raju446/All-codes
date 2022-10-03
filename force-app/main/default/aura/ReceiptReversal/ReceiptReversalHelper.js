/**
 * @File Name          : ReceiptReversalHelper.js
 * @Description        : 
 * @Author             : Jayanta Karmakar
 * @Group              : 
 * @Last Modified By   : Jayanta Karmakar
 * @Last Modified On   : 5/6/2020, 12:30:20 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/30/2020   Jayanta Karmakar     Initial Version
**/
({
	showToast: function(type, title, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title,
			"type": type,
			"message": message
		});
		toastEvent.fire();
	}
})