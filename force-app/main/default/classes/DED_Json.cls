public class DED_Json {
	
	public DED_Json(Account acc){
		UD_Input = new UD_Input(acc);
	}
	
	public class UD_Input {
		public ServiceCall serviceCall;
		public ModifyBLED modifyBLED;
		public UD_Input(Account acc){
			serviceCall = new serviceCall();
			modifyBLED = new ModifyBLED(acc);
		}
	}
	
	public class ServiceCall {
		public CBLSAuthenticate CBLSAuthenticate;
		public ServiceCall(){
			CBLSAuthenticate = new CBLSAuthenticate();
		}
	}

	public UD_Input UD_Input;

	public class OwnerRelationshipFZED {
		//public String OwnerNationality;
		//public String OwnerMobileNo;
		//public String OwnerPassportNo;
		public String RelationshipType;
		public DateTime  RelationShipStartDate;
		//public String OwnerVisaNo;
		public String RelationshipStatus;
		//public String OwnerDateOfBirth;
		//public String OwnerEmiratesID;
		//public String OwnerGender;
		public String EDOwnerID;
		//public String OwnerFullNameAR;
		public String OwnerTypeId;
		public String OwnerFullNameEN;
		//OwnerTypeId__c,RelationshipTypeID__c,
		public OwnerRelationshipFZED(Entity_Owner__c owner)
		{
			system.debug('===ownerinfor===='+owner);
			this.RelationshipType 		= owner.RelationshipTypeID__c;
			this.RelationShipStartDate 	= owner.RelationShip_Start_Date__c;
			this.RelationshipStatus 	= owner.Relationship_Status1__c;
			this.EDOwnerID 				= owner.EDOwnerID__c;
			this.OwnerTypeId 			= owner.OwnerTypeId__c;
			this.OwnerFullNameEN 		= owner.Owner_Full_Name_En__c;
		}
		public OwnerRelationshipFZED(){}
	}

	public class BLOwner {
		public List<OwnerRelationshipFZED> OwnerRelationshipFZED;
		public BLOwner(Account acc)
		{
			OwnerRelationshipFZED = new List<OwnerRelationshipFZED>();
			for(Entity_Owner__c owner : acc.Entity_Owners__r){
				OwnerRelationshipFZED ofz = new OwnerRelationshipFZED(owner);
				OwnerRelationshipFZED.add(ofz);
			}
			if(acc.Entity_Owners__r == null || acc.Entity_Owners__r.size() == 0)
			{
				OwnerRelationshipFZED ofz = new OwnerRelationshipFZED();
				if(acc.Entity_Type__c != null && acc.Entity_Type__c.contains('Foundation')){
					ofz.RelationshipType 		= '7';
					ofz.OwnerTypeId 			= '4';
				}else if(acc.Entity_Type__c != null && acc.Entity_Type__c.contains('Partnership')){
					ofz.RelationshipType 		= '9';
					ofz.OwnerTypeId 			= '6';
				}else{
					ofz.RelationshipType 		= '8';
					ofz.OwnerTypeId 			= '5';
				}
				ofz.RelationShipStartDate 	= acc.Registration_Date__c;
				ofz.RelationshipStatus 	= 'Y';
				ofz.EDOwnerID 				= acc.Entity_Id__c;
				ofz.OwnerFullNameEN 		= acc.Name;
				OwnerRelationshipFZED.add(ofz);
			}
		}
	}

	public class BusinessActivityFZED {
		public String ActivityStatus;
		public String BADescriptionEN;
		public String ActivityCode;
		public String BADescriptionAR;
		public BusinessActivityFZED(Business_Activity__c ba)
		{
			this.ActivityCode      = ba.Actual_Activity_code__c;
			this.ActivityStatus    = 'Y';
			this.BADescriptionAR 	= ba.Activity_Name_Arabic__c;
			this.BADescriptionEN 	= ba.Activity_Name__c;
		}
	}
	
	public class BusinessActivities {
		public List<BusinessActivityFZED> BusinessActivityFZED;
		public BusinessActivities(list<Business_Activity__c> activitieslist)
		{
			BusinessActivityFZED = new List<BusinessActivityFZED>();
			for(Business_Activity__c ba : activitieslist)
			{
				BusinessActivityFZED bafz = new BusinessActivityFZED(ba);
				BusinessActivityFZED.add(bafz);
		    }
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

	public class ModifyBLED {
		public String BNRegNameEn;
		public DateTime RegistrationDate;
		//public String BranchBNTextEn;
		public String EDLicenseID;
		//public String BranchBNTextAr;
		//public String LicensePhoneNo;
		public String LicenseType;
		public String LicenseAddrLine1;
		//public String LicenseMobPhoneNo;
		//public String LicenseAddrLine4;
		public BLOwner BLOwner;//---------
		public BusinessActivities BusinessActivities;//---------------
		public String LicenseAddrLine3;
		public String LicenseAddrLine2;
		//public String ParentLicenceIssuanceEDID;
		public String BranchBL;
		public Decimal EDID;
		public String LegalType;
		//public String LicenseFaxNo;
		//public String ParentLicenceEDLicenseID;
		//public String EDInitialApprovalID;
		public DateTime  ExpirationDate;
		public String LicenseStatus;
		public String BNRegNameAr;
		public String BNLocalID;
		//public String ForeignCompCertID;
		public ModifyBLED(Account acc){
			EDID				= 15;
			BNRegNameEn 		= acc.Name;
			RegistrationDate 	= acc.Registration_Date__c;
			EDLicenseID 		= acc.Entity_Id__c;
			BNLocalID			= acc.Entity_Id__c;
			LicenseType 		= '1';
			for(Address__c address : acc.Addresses__r)
			{
				LicenseAddrLine1     = address.State__c;
				LicenseAddrLine2     = address.Street_Name_of_Cluster_on_the_Island__c;
				LicenseAddrLine3     = address.Building_Name__c;
			}
			if(acc.Entity_Type__c != null && acc.Entity_Type__c.contains('Branch')){
				BranchBL = 'Y';
			}else{
				BranchBL = 'N'; 
			}
			LegalType            	= acc.LegalTypeID__c;
			LicenseStatus        	= acc.LicenseStatusID__c;
			ExpirationDate 			= acc.License_Expiry_Date__c;
			BNRegNameAr 			= acc.Account_Name_Arabic__c;
			this.BusinessActivities		= new BusinessActivities(acc.Business_Activities__r);
			this.BLOwner			= new BLOwner(acc);
		}
	}
}