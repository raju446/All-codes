/**
 * @description       : 
 * @author            : Jayanta Karmakar
 * @group             : 
 * @last modified on  : 24-05-2021
 * @last modified by  : Jayanta Karmakar
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   01-16-2021   Jayanta Karmakar   Initial Version
**/
import { LightningElement, track, wire} from 'lwc';
import serachCons from '@salesforce/apex/MergeContactController.getContactList';
import mergeContacts from '@salesforce/apex/MergeContactController.mergeContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class MergeContactComponent extends LightningElement {
    @track searchkeys = {};
    @track searchData;
    @track masterRecord = '';
    @track isModalOpen = false;
    @track isLoaded = false;
    
    closeModal(event){
        this.isModalOpen = false;
    }
    
    openModal(event){
        if(this.masterRecord){
            this.isModalOpen = true;    
        } else {
            this.showToast('Error','Please select the Master Record to Merge.','error','dismissable');
        }
    }
    
    handleCheckbox(event){
        let selectedRows = this.template.querySelectorAll('lightning-input');
        let count = 0;
        console.log(count);
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox' && selectedRows[i].checked) {
                count++;
            }
        }
        if(count > 10){
            this.showToast('Error','Maximum 10 records are allowed to merge.','error','dismissable');
            event.target.checked = false;
            /*if(selectedRows[i].value == event.target.value){
                selectedRows[i].checked = false;
            }*/
        }
    }
    
    handleInpVal(event) {
        this.searchkeys[event.target.name] = event.target.value;
    }
    
    handleSearch() {
        if(!this.searchkeys.inpEmail && !this.searchkeys.inpFName && !this.searchkeys.inpLNam && !this.searchkeys.inpPassport && !this.searchkeys.inpNationality) {
            this.showToast('Info','Please enter above fields to search.','info','dismissable');
            return;
        }

        serachCons({conEmail : this.searchkeys.inpEmail, firstNam : this.searchkeys.inpFName, lastNam : this.searchkeys.inpLName, passportNo : this.searchkeys.inpPassport, nationality : this.searchkeys.inpNationality})
        .then(result => {
            console.log(result);  
            for(let i =0;i<result.length;i++){
                result[i]['link'] = '/'+result[i].Id;
            }
            console.log(result); 
            this.searchData = result;    
            //console.log(JSON.stringify(this.searchData));     
        })
        .catch(error => {
            window.console.log('error =====> '+JSON.stringify(error));
            if(error) {
                this.showToast('Error',error.body.message,'error','dismissable');
            }
        }) 
    }
    
    handleClear(){
        console.log('clear button called');
        this.searchkeys = {};
        this.searchData = undefined;
        this.masterRecord = '';
        let selectedRows = this.template.querySelectorAll('lightning-input');
        for(let i = 0; i < selectedRows.length; i++) {
            console.log(selectedRows[i].type);
            if(selectedRows[i].type === 'text') {
                selectedRows[i].value = '';
                console.log(selectedRows[i].value);
            }
        }
    }
    
    handleRadio(event){
        this.masterRecord = event.target.value;
        let selectedRows = this.template.querySelectorAll('lightning-input');
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                if(selectedRows[i].value == event.target.value){
                    selectedRows[i].disabled = true;
                } else {
                    selectedRows[i].disabled = false;
                }
            }
        }
    }
    
    mergeRecords(){
        this.isModalOpen = false;
        this.duplicateLst = [];
        let selectedRows = this.template.querySelectorAll('lightning-input');
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox' && selectedRows[i].checked) {
                this.duplicateLst.push(selectedRows[i].value);
            }
        }
        this.isLoaded = true;
        //@wire(mergeContacts, { masterRecord: this.masterRecord,  contsToMerge : this.duplicateLst})cons;
        mergeContacts({masterRecord: this.masterRecord,  contsToMerge : this.duplicateLst})
        .then(result => {
            console.log(result);    
            if(result == 'Success'){
                this.handleSearch();
                this.showToast('Success','Record Merged Successfully.','success','dismissable');
            } else {
                this.showToast('Error',result,'error','dismissable');
            }
            this.isLoaded = false; 
        })
        .catch(error => {
            window.console.log('error =====> '+JSON.stringify(error));
            if(error) {
                this.showToast('Error',error.body.message,'error','dismissable');
                this.isLoaded = false;
            }
        }) 
    }
    
    showToast(titl,msg,typ,mod) {
        const evt = new ShowToastEvent({
            title: titl,
            message: msg,
            variant: typ,
            mode: mod
        });
        this.dispatchEvent(evt);
    }
}