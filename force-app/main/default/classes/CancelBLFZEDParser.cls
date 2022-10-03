public class CancelBLFZEDParser {
	
	public CancelBLFZEDParser(Account acc){
		UD_Input = new UD_Input(acc);
	}

	public class ServiceCall {
		public CBLSAuthenticate CBLSAuthenticate;
		public ServiceCall(){
			CBLSAuthenticate = new CBLSAuthenticate();
		}
	}

	public class CancelBLED {
		public Datetime CancellationDate;
		public String EDLicenseID;
		public Decimal EDID;
		public CancelBLED(Account acc){
			this.CancellationDate = acc.Cancellation_Date__c;
			this.EDLicenseID = acc.Entity_Id__c;
			this.EDID = 15;
		}
	}

	public class CBLSAuthenticate {
		public String Username;
		public String Password;
		public CBLSAuthenticate(){
			Password = system.label.DED_Pwd;
			Username = system.label.DED_UserName;
		}
	}

	public class UD_Input {
		public ServiceCall serviceCall;
		public CancelBLED cancelBLED;
		public UD_Input(Account acc){
			serviceCall = new serviceCall();
			cancelBLED = new CancelBLED(acc);
		}
	}

	public UD_Input UD_Input;

}