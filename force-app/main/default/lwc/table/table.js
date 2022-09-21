import { LightningElement,track } from 'lwc';
export default class Samplecomponent extends LightningElement {
    @track isModalOpen = false;
    @track taskDetails;
    @track firstName;
    @track lastName;
    @track Phone;
    @track Email;

    TodoId = 1;  
    @track person = [{
        id:1,
        firstName:'',
        lastName: '',
        Phone: '',
        Email: ''
      }];
    
   
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    handleFormFirstInputChange(event) {
        
        this.firstName =  event.target.value;
    }
    handleFormLastChange(event) {
        
        this.lastName =  event.target.value;
    }
    handleFormPhoneChange(event) {
        
        this.Phone =  event.target.value;
    }
    handleFormEmailChange(event) {
        
        this.Email =  event.target.value;
    }

    updateText(){
        
        this.TodoId = this.TodoId + 1;
          this.person = [
              ...this.person,
              {
                  id: this.TodoId,
                  firstName: this.firstName,
                  lastName: this.lastName,
                  Phone: this.Phone,
                  Email: this.Email
              }
          ];
      }
   
}