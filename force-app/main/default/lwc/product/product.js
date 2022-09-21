import { LightningElement, track, wire} from 'lwc';
import getproductList from '@salesforce/apex/product.getproductList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class product extends LightningElement {
  @track openModal = false;
  showModal() {
      this.openModal = true;
  }
  closeModal() {
      this.openModal = false;
  } 

  columns = [{
    label: 'Account name',
    fieldName: 'Name',
    type: 'text',
    sortable: true
},
{
    label: 'Type',
    fieldName: 'Opportunity__c',
    type: 'Loockup',
    sortable: true
},
{
    label: 'Annual Revenue',
    fieldName: 'Description__c',
    type: 'Text',
    sortable: true
},
{
    label: 'Phone',
    fieldName: 'price__c',
    type: 'Currency',
    sortable: true
},
{
    label: 'Website',
    fieldName: 'Quantity__c',
    type: 'Number',
    sortable: true
},
{type: "button",label:'button',
     typeAttributes: {  
    label: 'View',  
    fieldName: 'View',    
    disabled: false,  
    type: 'view',  
    iconPosition: 'left',
 
}},  
];

@track error;
@track accList ;
@wire(getproductList)
wiredAccounts({
error,
data
}) {
if (data) {
    this.accList = data;
} else if (error) {
    this.error = error;
}
}

      handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'prduct is created',
                variant: 'success',
            })
        );
    }

    handleSubmit(event){
        event.preventDefault()
        const fields = event.detail.fields;
        console.log(JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'product created',
                variant: 'success',
            })
            .catch(error => {
                this.error = error.message; 
            })
        );
           location.reload();
     }
}