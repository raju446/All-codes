import { LightningElement, wire } from "lwc";
import getOpportunities from "@salesforce/apex/Restaurantedit.getOpportunities";
import { NavigationMixin } from "lightning/navigation";
const OPPORTUNITY_COLS = [
{
        label: "Name",
        type: "button",
        typeAttributes: { label: { fieldName: "Name" }, name: "gotoOpportunity", variant: "narrow" }
},
{ label: "Person Name",
    fieldName: "BOOKING_NAMES__c",
    type: "text"
},
{ label: "Place",
    fieldName: "LOCATION__c",
    type: "Geolocation"
},
{
        label: "Date",
        type: "date",
        fieldName: "BOOKING_DATE__c"
},
{
         label: "Booking Number", 
    type: "Number",
     fieldName: "BOOKING_NUMBER__c"
},
{  label: "MENU ITEMS",
     type: "picklist", 
     fieldName: "MENU_ITEMS__c" 
},
{
     label: "setting",
      type: "picklist", 
      fieldName: "SETTING_TYPE__c"
},
{ 
    label: "SERVERS TIP",
     type: "Number", 
     fieldName: "SERVERS_TIP__c"
},
{ 
    label: "Bill",
     type: "Currency", 
     fieldName: "BILL__c" 
},
{
        label: "Edit",
        type: "button",
        typeAttributes: {
            label: "Edit",
            name: "editrestaurant__c",
            variant: "brand"
}
}
];

export default class editpopup extends NavigationMixin(LightningElement) {
    opportunityCols = OPPORTUNITY_COLS;

    @wire(getOpportunities, {})
    restaurant__c;

    handleRowAction(event) {
        if (event.detail.action.name === "gotoOpportunity") {
            this[NavigationMixin.GenerateUrl]({
                type: "standard__recordPage",
                attributes: {
                    recordId: event.detail.row.Id,
                    actionName: "view"
                }
            }).then((url) => {
                window.open(url, "_blank");
            });
        }
        if (event.detail.action.name === "editrestaurant__c") {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: event.detail.row.Id,
                    actionName: "edit"
                }
            });
        }
    }
}