import { LightningElement,track } from 'lwc';
export default class Samplecomponent extends LightningElement {
    @track isModalOpen = false;
    @track outputText;
    updateText(event) {
        this.outputText = this.template.querySelector('lightning-input').value;
    }
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }
    handleFormInputChange(event) {
        this[event.target.FirstName] = event.detail.value;
    }
    handleFormInputChange(event) {
        this[event.target.LastName] = event.detail.value;
    }
    handleFormInputChange(event) {
        this[event.target.Age] = event.detail.value;
    }
}