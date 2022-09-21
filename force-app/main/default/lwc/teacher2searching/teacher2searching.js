import { LightningElement, track, wire } from 'lwc';
import retrieveContactData from '@salesforce/apex/teachersearch.retrieveContactData';

export default class teacher2searching extends LightningElement {

   @track currentteacherName;
   @track searchteacherName;
    handleChangetccName(event){
        alert("Enter the teacher name");
      this.currentteacher2__r.Name = event.target.value;      
    }

    handleAccountSearch(){
        alert("search the name");
       this.searchteacher2__r.Name = this.currentteacher2__r.Name;
    }
   
    @track records;
    @track dataNotFound;
    @wire (retrieveContactData,{keySearch:'$searchteacher__r.Name'})
    wireRecord({data,error}){
        if(data){           
            this.records = data;
            this.error = undefined;
            this.dataNotFound = '';
            if(this.records == ''){
                this.dataNotFound = 'There is no student found related to teacher name';
            }

           }else{
               this.error = error;
               this.data=undefined;
           }
    }
}