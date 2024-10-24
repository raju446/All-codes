import { LightningElement, track, api } from 'lwc';
import sendOTP from '@salesforce/apex/TwilioVerifyService.sendOTP';
import verifyOTP from '@salesforce/apex/TwilioVerifyService.verifyOTP';
import loginUserByMobileNumber from '@salesforce/apex/TwilioVerifyService.loginUserByMobileNumber';

export default class loginComponent extends LightningElement {
    @track mobileNumber = '';
    @track loginmobileNumber = '';
    @track otp = '';
    @track remainingTime = 0;
    @track message = '';
    @track showverify = false;
    @track showotpinp =  false;
    @track resendoTp = false;
    @track type;
    @track message;
    @track showToastBar = false;
    @track result = {};
    @track email = '';
    @api autoCloseTime = 5000;


    /*connectedCallback() {
        this.startTimer();
    }*/

    startTimer() {
        if (this.timerInterval) {
            clearInterval(this.timerInterval);
        }
        
        this.timerInterval = setInterval(() => {
            if (this.remainingTime > 0) {
                this.remainingTime -= 1;
            } else {
                clearInterval(this.timerInterval);
                this.showotpinp = false;
                this.showverify = false;
                this.resendoTp = true;
                console.log('1.....');
            }
        }, 1000);
    }

    closeModel() {
        this.showToastBar = false;
        this.type = '';
        this.message = '';
	}

    get getIconName() {
        return 'utility:' + this.type;
    }

    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }

    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }

    handleMobileNumberChange(event){
        this.mobileNumber = event.target.value;
        console.log('this.mobileNumber------'+this.mobileNumber);
        if (!this.isValidMobileNumber(this.mobileNumber)) {
            this.message = 'Please enter a valid Mobile Number';
            this.type = 'error';
            setTimeout(() => {
                this.closeModel();
            }, this.autoCloseTime);
        }
        //if(this.mobileNumber.length === 12){
       /* }
        else {
            this.message = 'Please Enter Mobile Number With Country Code EX:- 91';
            this.type = 'error';
            this.showToastBar = true;
            setTimeout(() => {
                this.closeModel();
            }, this.autoCloseTime);
        }*/
    }

    handleloginMobileNumberChange(event){
        this.loginmobileNumber = event.target.value;
       /* if(this.loginmobileNumber.length !== 12){
            this.showToastBar = true;
            if(this.loginmobileNumber.length < 12){
                this.message = 'Please Enter Mobile Number With Country Code EX:- 91';
            } else if(this.loginmobileNumber.length > 12){
                this.message = 'Please Enter your 10digits Mobile Number with Country Code';
            }
            this.type = 'error';
            setTimeout(() => {
                this.closeModel();
            }, this.autoCloseTime);
        } else {
            this.handleLogin();
        }*/  //set validation by tommorrow
    }

    handleEmailChange(event){
        this.email = event.target.value;
        console.log('email------'+this.email);
        this.handleSendOTP();
    }

    handleInput(event) {
        const target = event.target;
        const val = target.value;

        // Allow only numeric input
        if (isNaN(val)) {
            target.value = '';
            return;
        }

        // Append value to finalValue
        const index = [...this.template.querySelectorAll('.input')].indexOf(target);
        const finalValueArray = this.finalValue.split('');
        finalValueArray[index] = val;
        this.finalValue = finalValueArray.join('');

        // Move to the next input if value is filled
        if (val !== "") {
            const next = target.nextElementSibling;
            if (next && next.classList.contains('input')) {
                next.focus();
            }
        } 
    }

    handleKeyDown(event) {
        const target = event.target;
        const key = event.key.toLowerCase();

        // Handle backspace and delete key
        if (key === 'backspace' || key === 'delete') {
            event.preventDefault(); // Prevent default delete/backspace behavior
            target.value = ''; // Clear the current input

            // Move focus to the previous input
            const prev = target.previousElementSibling;
            if (prev && prev.classList.contains('input')) {
                prev.focus();
            }

            // Remove the value from the finalValue string
            const index = [...this.template.querySelectorAll('.input')].indexOf(target);
            const finalValueArray = this.finalValue.split('');
            finalValueArray[index] = '';
            this.otp = finalValueArray.join('');
        }
    }

    handleSendOTP() {
        sendOTP({ toPhoneNumber: this.mobileNumber,  email: this.email})
            .then(result => {
                this.message = result;
                this.type = 'success';
                this.showotpinp = true;
                this.remainingTime = 30;
                this.startTimer();
                this.showToastBar = true;
                this.resendoTp = false;
                setTimeout(() => {
                    this.closeModel();
                }, this.autoCloseTime);
            })
            .catch(error => {
                this.message = error.body.message || JSON.stringify(error);
                this.type = 'error';
                this.showotpinp = false;
                this.showToastBar = true;
                setTimeout(() => {
                    this.closeModel();
                }, this.autoCloseTime);
            });
    }

    handleVerifyOTP() {
        verifyOTP({ toPhoneNumber: this.mobileNumber, email: this.email, otp: this.otp })
            .then(result => {
                this.message = 'User created successfully.';
                this.type = 'success';
                this.showToastBar = true;
                window.location.href = result;   
                setTimeout(() => {
                    this.closeModel();
                }, this.autoCloseTime);
            })
            .catch(error => {
                this.message = error.body.message? error.body.message :JSON.stringify(error);
                this.type = 'error';
                this.showToastBar = true;
                setTimeout(() => {
                    this.closeModel();
                }, this.autoCloseTime);
            });
    }

    handlelogin() {
        loginUserByMobileNumber({ loginmobileNumber: this.loginmobileNumber })
            .then(loginUrl => {
                this.message = 'User login successfully.';
                this.type = 'success';
                this.showToastBar = true;
                window.location.href = loginUrl;
                setTimeout(() => {
                    this.closeModel();
                }, this.autoCloseTime);
            })
            .catch(error => {
                this.message = error.body.message? error.body.message :JSON.stringify(error);
                this.type = 'error';
                this.showToastBar = true;
                setTimeout(() => {
                    this.closeModel();
                }, this.autoCloseTime);
            });
    }

    handleGoogleLogin() {
        //alert('1');
        const loginUrl = 'https://dream-force-dev-ed.develop.my.site.com/Boat/services/auth/sso/Google';
        window.location.href = loginUrl;
    }

    isValidMobileNumber(mobileNumber) {
        const mobilePattern = /^[789][0-9]{9}$/;
        return mobilePattern.test(mobileNumber);
    }

    handleResendOTP() {
        this.handleSendOTP();
    }
}