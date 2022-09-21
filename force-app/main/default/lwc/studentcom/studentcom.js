import { LightningElement, track, wire,api } from 'lwc';
import retrieveContactData from '@salesforce/apex/studentapex.retrieveContactData';

export default class DisplaystudentOnteacherName extends LightningElement {

   @track currentteacherName;
   @track searchteacherName;
    handleChangeAccName(event){
      this.currentteacherName = event.target.value;      
    }

    handleAccountSearch(){
        alert("1");
       this.searchteacher2__r.Name = this.currentteacher2__r.Name;
    }
   @api keySearch;
    @track records;
    @track dataNotFound;
    @wire (retrieveContactData,{keySearch:'$searchteacher2__r.Name'})
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