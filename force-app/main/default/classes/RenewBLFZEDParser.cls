public class RenewBLFZEDParser {

	public RenewBLFZEDParser(Account acc){
		UD_Input = new UD_Input(acc);
	}
	public class ServiceCall {
		public CBLSAuthenticate CBLSAuthenticate;
		public ServiceCall(){
			CBLSAuthenticate = new CBLSAuthenticate();
		}
	}

	public class RenewBLED {
		public DateTime ExpirationDate;
		public String EDLicenseID;
		public Decimal EDID;
		public RenewBLED(Account acc)
		{
			this.ExpirationDate = acc.License_Expiry_Date__c;
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
		public RenewBLED renewBLED;
		public UD_Input(Account acc){
			serviceCall = new serviceCall();
			renewBLED = new RenewBLED(acc);
		}
	}

	public UD_Input UD_Input;
	
}