import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/studentrecordedit.getAccounts';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const columns = [
  {
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
    }, {
        label: 'BOOKING NAMES',
        fieldName: 'BOOKING_NAMES__c',
        type: 'text',
        editable: true,
    }, {
        label: 'Booking date',
        fieldName: 'BOOKING_DATE__c',
        type: 'date',
        
        editable: true,
    }, {
        label: 'Booking Number',
        fieldName: 'BOOKING_NUMBER__c',
        type: 'number',
        editable: true
    }, {
        label: 'Setting Type',
        fieldName: 'SETTING_TYPE__c',
        type: 'picklist',
        editable: true
    }, {
        label: ' Menu items',
        fieldName: 'MENU_ITEMS__c',
        type: 'picklist',
        editable: true
    }, {
        label: 'Bill',
        fieldName: 'BILL__c',
        type: 'currency',
        editable: true
    }  
    
    
];
export default class studentrecordedit extends LightningElement {
    columns = columns;
    @track accObj;S
    fldsItemValues = [];

    @wire(getAccounts)
    cons(result) {
        this.accObj = result;
        if (result.error) {
            this.accObj = undefined;
        }
    };

    saveHandleAction(event) {
        this.fldsItemValues = event.detail.draftValues;
        const inputsItems = this.fldsItemValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

       
        const promises = inputsItems.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records Updated Successfully!!',
                    variant: 'success'
                }) 
            );
            this.fldsItemValues = [];
            return this.refresh();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An Error Occured!!',
                    variant: 'error'
                })
            );
        }).finally(() => {
            this.fldsItemValues = [];
        });
    }

   
    async refresh() {
        await refreshApex(this.accObj);
    }
}