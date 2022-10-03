import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class employeevisaform extends LightningElement {
    @track buttonVisible = false;
    @track isLoaded = false;
      handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Employee visa form submited.',
                variant: 'success',
            })
        );
    }
    handleChange(event) {
        this.buttonVisible = event.target.value;
    }
    handleError(event) {
       // console.log("handleError event");
       // console.log(JSON.stringify(event.detail));
    }
    handleSubmit(event){
        event.preventDefault()
        const fields = event.detail.fields;
        console.log(JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Employee visa form submited.',
                variant: 'success',
            })
        );

        location.reload();
     }
}