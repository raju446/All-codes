import { LightningElement} from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import conMainObject from '@salesforce/schema/student2__c';
import conName from '@salesforce/schema/student2__c.Name';
import congender from '@salesforce/schema/student2__c.gender__c';
import conresults from '@salesforce/schema/student2__c.results__c';
import confees from '@salesforce/schema/student2__c.fees__c';
import conmarks from '@salesforce/schema/student2__c.marks__c';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class InsertContactRecordLwc extends NavigationMixin(LightningElement) {

    firstName = '';
    lastName = '';
    phoneNo= '';
    emailId='';
    departmentVal='';
    descriptionVal='';

    contactChangeVal(event) {
        console.log(event.target.label);
        console.log(event.target.value);        
        if(event.target.label=='Name'){
            this.firstName = event.target.value;
        }
        if(event.target.label=='gender__c'){
            this.lastName = event.target.value;
        }            
        if(event.target.label=='results__c'){
            this.phoneNo = event.target.value;
        }
        if(event.target.label=='fees__c'){
            this.emailId = event.target.value;
        }
        if(event.target.label=='marks__c'){
            this.departmentVal = event.target.value;
        }        
        
        
    }


    insertContactAction(){
        console.log(this.selectedAccountId);
        const fields = {};
        fields[conName.fieldApiName] = this.Name;
        fields[congender.fieldApiName] = this.gender__c;
        fields[confees.fieldApiName] = this.fees__c;
        fields[conresults.fieldApiName] = this.results__c;
        fields[conmarks.fieldApiName] = this.marks__c;
       
        const recordInput = { apiName: conMainObject.objectApiName, fields };
        createRecord(recordInput)
            .then(contactobj=> {
                this.contactId = contactobj.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact record has been created',
                        variant: 'success',
                    }),
                );
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: contactobj.id,
                        objectApiName: 'Contact',
                        actionName: 'view'
                    },
                });



            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

}