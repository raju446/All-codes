import { LightningElement, wire } from "lwc";
import getOpportunities from "@salesforce/apex/editpopup.getOpportunities";
import { NavigationMixin } from "lightning/navigation";
const OPPORTUNITY_COLS = [
    {
        label: "Name",
        type: "button",
        typeAttributes: { label: { fieldName: "Name" }, name: "gotoOpportunity", variant: "base" }
    },
    { label: "results",
    fieldName: "results__c",
    type: "picklist"
    },
    {
        label: "gender",
        type: "picklist",
        fieldName: "gender__c"
    },
    { label: "marks", type: "Number", fieldName: "marks__c" },
    { label: "fees", type: "Currency", fieldName: "fees__c" },
    {
        label: "Edit",
        type: "button",
        typeAttributes: {
            label: "Edit",
            name: "editstudent2__c",
            variant: "brand"
        }
    }
];

export default class editpopup extends NavigationMixin(LightningElement) {
    opportunityCols = OPPORTUNITY_COLS;

    @wire(getOpportunities, {})
    student2__c;

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
        if (event.detail.action.name === "editstudent2__c") {
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