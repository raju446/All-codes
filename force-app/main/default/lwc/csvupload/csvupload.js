import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import csvFileRead from '@salesforce/apex/csvupload.csvFileRead';
export default class FileUploaderCompLwc extends LightningElement {
    @api recordId;
    @track fileData;
    @track result;
    @track columns

    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
            'recordId': this.fileData
            }
            console.log('data',file);
        }
        reader.readAsDataURL(file)
    }

get columns(){
        const columns = [
         { label: 'AccountName',fieldName: 'Name',Type:'text'},
         { label: 'AccountSource',fieldName: 'AccountSource',Type:'picklist'},
         { lable: 'Description' ,fieldName: 'Description',Type:'LongTextArea'}
        ];
        console.log('datacolumns',columns);
        return columns; 
    } 
    get rows(){
        if(this._rows){
            return this._rows.map((row, index) => {
                row.key = index;
                if(this.results[index]){
                    row.result = this.results[index].id || this.result[index].error;
                }
                console.log('datarows',rows);
                return row;
            })
        }
        return [];
    }

    handleClick(){
        const {base64, filename, recordId} = this.fileData
        csvFileRead({ base64, filename, recordId }).then(result=>{
           
            this.fileData = null
           
            console.log('results', filename);
            let title = `${filename} uploaded successfully!!`
            this.toast(title)
        })
    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }
cancel(){
     this.fileData = undefined;
        this.result = undefined;
 }
}