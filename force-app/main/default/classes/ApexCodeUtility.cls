/*
    Author      : Durga Prasad
    Company     : PwC
    Date        : 17-Sep-2017
    Description : Utility class with generic methods
    -------------------------------------------------------------------------
v1.1    12/Jan/2020     Ravi        Added the logic to apply the fine on PO Box renewal from March 1st as per Business request(mail)
*/
public without sharing class ApexCodeUtility{
    public static boolean CaseTriggerRecursive = false;
    public static boolean LeadTriggerRecursive = false;
    public static boolean OpportunityTriggerRecursive = false;
    public static boolean ContactTriggerRecursive = false;
    public static boolean isNotRecursive = true;
    public static boolean CaseOwnerChange = true;
    public static boolean isNotRecursiveForAccountUpdate = true;
    
    public static string strCryptoKey = '14713678901234567890123456713741';//12345678901234567890123456789012
    public static string getEncryptedValueURL(string strdata){
        system.debug('Actual Data in Encrypt Method==>'+strdata);
        Blob keyblobval = Blob.valueOf(strCryptoKey);
        Blob EncryptedPasswordBlob = Crypto.encryptWithManagedIV('AES256', keyblobval, Blob.valueOf(strdata));
        string EncryptedData = EncodingUtil.base64Encode(EncryptedPasswordBlob); 
        system.debug('sEncryptedData==>'+EncryptedData);
        return EncodingUtil.urlEncode(EncryptedData,'UTF-8');
    }
    public static string getEncryptedValue(string strdata){
        system.debug('Actual Data in Encrypt Method==>'+strdata);
        Blob keyblobval = Blob.valueOf(strCryptoKey);
        Blob EncryptedPasswordBlob = Crypto.encryptWithManagedIV('AES256', keyblobval, Blob.valueOf(strdata));
        string EncryptedData = EncodingUtil.base64Encode(EncryptedPasswordBlob); 
        system.debug('sEncryptedData==>'+EncryptedData);
        return EncryptedData;
    }
    public static string getDecryptedValue(string strdata){
        Blob keyblobval = Blob.valueOf(strCryptoKey);
        system.debug('Data in Decrypt Method==>'+strdata);
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(strdata);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', keyblobval, encodedEncryptedBlob);
        String decryptedData = decryptedBlob.toString();
        System.debug('decryptedData==>'+decryptedData);
        return decryptedData;
    }
    public static string getDecryptedValueURL(string strdata){
        Blob keyblobval = Blob.valueOf(strCryptoKey);
        system.debug('Data in Decrypt Method==>'+strdata);
        strdata = Encodingutil.urlDecode(strdata.replaceAll('_', '%'),'UTF-8');
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(strdata);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', keyblobval, encodedEncryptedBlob);
        String decryptedData = decryptedBlob.toString();
        System.debug('decryptedData==>'+decryptedData);
        return decryptedData;
    }
    public static String isExistingPortalUser(String emailStr){
        String existingUser = '';
        String newUserEmail = emailStr;
        newUserEmail = newUserEmail.substringBefore('@');
        newUserEmail = newUserEmail + '@adgm.portal';   
        List<User> existUser = [SELECT Id, Username FROM User WHERE Username = :newUserEmail AND isActive = TRUE];
        if(!existUser.isEmpty()){
            existingUser = existUser[0].Username ;
        }
        return existingUser ; 
    }
    public static String isExistingUsername(String username){
        String existingUser = '';
        //String newUserEmail = username + '@adgm.portal';  
        String newUserEmail = username;  
        List<User> existUser = [SELECT Id, Username FROM User WHERE Username = :newUserEmail AND isActive = TRUE];
        if(!existUser.isEmpty()){
            existingUser = existUser[0].Username ;
        }
        return existingUser ; 
    }
    public static String isExistingUsernameSR(String username){
        String existingUser = '';
        String newUserEmail = username;  
        List<HexaBPM__Service_Request__c> existUser = [SELECT Id, Guest_Username__c FROM HexaBPM__Service_Request__c WHERE Guest_Username__c = :newUserEmail AND HexaBPM__External_Status_Name__c = 'Submitted'];
        if(!existUser.isEmpty()){
            existingUser = existUser[0].Guest_Username__c;
        }
        return existingUser ; 
    }
    public static decimal getOpenReceiptsAmount(string EntityId){
        decimal Amount = 0.0;
        if(EntityId!=null){
            for(Receipt__c RP:[select Id,Amount__c from Receipt__c where Entity__c=:EntityId and Oracle_Receipt_Id__c=null and Amount__c!=null and Payment_Currency__c != 'USD' and (Status__c='Success' or Status__c='Approved') and Receipt_Type__c != 'Fund Transfer']){
                Amount = Amount + RP.Amount__c;
            }
        }
        return Amount;
    }
    public static decimal getBlockedAmount(string EntityId){
        decimal Amount = 0.0;
        if(EntityId!=null){
            for(HexaBPM__SR_Price_Item__c SRP:[select Id,HexaBPM__Price__c,Tax_Amount__c,Total_Amount__c from HexaBPM__SR_Price_Item__c where HexaBPM__ServiceRequest__r.HexaBPM__Customer__c=:EntityId and (HexaBPM__Status__c='Blocked' or HexaBPM__Status__c='Consumed') and Total_Amount__c!=null]){
                Amount = Amount + SRP.Total_Amount__c;
            }
        }
        return Amount;
    }
    public static List<HexaBPM__SR_Price_Item__c> createPOBoxPriceItems(HexaBPM__Service_Request__c objSR){
    
        map<string,list<Fines__c>> mapFineTypes = new map<string,list<Fines__c>>();
        for(Fines__c fine : Fines__c.getAll().values()){
            list<Fines__c> lstFines = new list<Fines__c>();
            if(mapFineTypes.get(fine.SR_Record_Type_Name__c.toLowerCase())!=null)
                lstFines = mapFineTypes.get(fine.SR_Record_Type_Name__c.toLowerCase());
            lstFines.add(fine);
            mapFineTypes.put(fine.SR_Record_Type_Name__c.toLowerCase(),lstFines);
        }
    
        String poBoxCode = 'P_O_BOX_FEES';
        List<Product2> objPOBoxProduct = [SELECT Id FROM Product2 WHERE ProductCode = :poBoxCode];
        
        Integer ADGM_SERVICE_CHARGE_FEE = 0;
        if(Label.ADGM_SERVICE_CHARGE_FEE != '' && Label.ADGM_SERVICE_CHARGE_FEE != null){
            ADGM_SERVICE_CHARGE_FEE = Integer.valueOf(Label.ADGM_SERVICE_CHARGE_FEE);
        }
        Integer ADGM_NEW_PO_BOX_FEE = 0;
        if(Label.ADGM_NEW_PO_BOX_FEE != '' && Label.ADGM_NEW_PO_BOX_FEE != null){
            ADGM_NEW_PO_BOX_FEE = Integer.valueOf(Label.ADGM_NEW_PO_BOX_FEE );
        }
        
        List<HexaBPM__SR_Price_Item__c> srPriceItemsTBI = new List<HexaBPM__SR_Price_Item__c>();
        
        //PO BOX NEW
        if(objSR.HexaBPM__Record_Type_Name__c == 'P_O_Box_New'){
            system.debug('@@POBOX_NEW');
            
            //Create Amount : New PO BOX = fees(based on month) + ADGM Fees(250) + New PO BOX fee (100) 
            //System.debug('@@SUBMITTEDDATE: '+objSR.HexaBPM__Submitted_Date__c);
            Decimal fee = 0;
            Integer startMonth = System.Today().month();
            Decimal Tempfee = ApexCodeUtility.getAnnualAmount(startMonth, objSR.P_O_Box_Type__c);
            
            if(Tempfee!=null)
                fee = Tempfee;
            HexaBPM__SR_Price_Item__c objPriceItem = new HexaBPM__SR_Price_Item__c();
            objPriceItem.HexaBPM__ServiceRequest__c = objSR.Id;
            objPriceItem.Entity__c  = objSR.HexaBPM__Customer__c;
            objPriceItem.HexaBPM__Product__c = objPOBoxProduct[0].Id;
            objPriceItem.HexaBPM__Price__c = fee + ADGM_SERVICE_CHARGE_FEE + ADGM_NEW_PO_BOX_FEE;
            objPriceItem.Markup_Amount__c = ADGM_SERVICE_CHARGE_FEE;
            objPriceItem.Cost__c = fee+ADGM_NEW_PO_BOX_FEE;
            objPriceItem.Tax_Amount__c = objPriceItem.Markup_Amount__c * 5 / 100;
            objPriceItem.HexaBPM__Sys_Added_through_Code__c = true;
            objPriceItem.HexaBPM__Non_Reevaluate__c = true;
            srPriceItemsTBI.add(objPriceItem);
        }
        
        //PO BOX RENEWAL
        if(objSR.HexaBPM__Record_Type_Name__c == 'P_O_Box_Renewal'){
            
            system.debug('@@POBOX_RENEWAL');
            system.debug('@@POBOX_EXPIRY: '+objSR.Entity_PO_Box_Expiry_Date__c);
            
            Integer startMonth = System.Today().month();
            Integer startYear = System.Today().year();
            
            Integer expiryMonth = 0;
            if(objSR.Entity_PO_Box_Expiry_Date__c != null){
                expiryMonth = objSR.Entity_PO_Box_Expiry_Date__c.month();
                if(System.Today() < objSR.Entity_PO_Box_Expiry_Date__c){
                    startMonth = 1;
                }
            }
            
            Decimal fineAmount = 0;
            //v1.1
            Date fineDate = Date.newInstance(system.today().year(), 3, 1);

            if(objSR.Entity_PO_Box_Expiry_Date__c < System.Today() && fineDate <= system.today() ){
                for(Fines__c fines : mapFineTypes.get(objSR.HexaBPM__Record_Type_Name__c.toLowerCase())){
                    if(expiryMonth > 1){
                        fineAmount = fineAmount + fines.First_Month_Amount__c;
                        if(expiryMonth > 2){
                            //fineAmount = fineAmount + ((expiryMonth - 2) * fines.Fine_Amount_Per_Month__c);
                            fineAmount = fineAmount + ((System.Today().month() - 1) * fines.Fine_Amount_Per_Month__c);
                            if(expiryMonth == 12 && (objSR.Entity_PO_Box_Expiry_Date__c.year() + 1) > System.Today().year()){
                                fineAmount = fineAmount + 30;
                            }
                        }
                    }
                }
            }
            //System.debug('@@SUBMITTEDDATE: '+objSR.HexaBPM__Submitted_Date__c);
            
            String poBoxType = '';
            List<PO_Box__c> existPOBox = [SELECT Id, P_O_Box_Selected_Bundle__c FROM PO_Box__c WHERE Id = :objSR.PO_Box__c];
            system.debug('@@PO: '+existPOBox);
            if(existPOBox.size() > 0 && existPOBox[0].P_O_Box_Selected_Bundle__c != '' && existPOBox[0].P_O_Box_Selected_Bundle__c != null){
                poBoxType = existPOBox[0].P_O_Box_Selected_Bundle__c;
            }
            Decimal fee = 0;
            Decimal Tempfee = ApexCodeUtility.getAnnualAmount(startMonth, poBoxType);
            
            if(Tempfee!=null)
                fee = Tempfee;
            System.debug('##FEE: '+fee);
            System.debug('##FINE: '+fineAmount);
            HexaBPM__SR_Price_Item__c objPriceItem = new HexaBPM__SR_Price_Item__c();
            objPriceItem.HexaBPM__ServiceRequest__c = objSR.Id;
            objPriceItem.Entity__c  = objSR.HexaBPM__Customer__c;
            objPriceItem.HexaBPM__Product__c = objPOBoxProduct[0].Id;
            objPriceItem.HexaBPM__Price__c = fee + ADGM_SERVICE_CHARGE_FEE + fineAmount;
            objPriceItem.Markup_Amount__c = ADGM_SERVICE_CHARGE_FEE;
            //objPriceItem.Cost__c = 0;
            objPriceItem.Cost__c = fee+fineAmount;
            objPriceItem.Tax_Amount__c = objPriceItem.Markup_Amount__c * 5 / 100;
            objPriceItem.HexaBPM__Sys_Added_through_Code__c = true;
            objPriceItem.HexaBPM__Non_Reevaluate__c = true;
            srPriceItemsTBI.add(objPriceItem);
        }
        
        //PO BOX CANCELLATION
        if(objSR.HexaBPM__Record_Type_Name__c == 'P_O_Box_Cancellation'){
            system.debug('@@POBOX_CANCELLATION');
            
            Integer startMonth = System.Today().month();
            Integer startYear = System.Today().year();
            
            Integer expiryMonth = 0;
            if(objSR.Entity_PO_Box_Expiry_Date__c != null){
                expiryMonth = objSR.Entity_PO_Box_Expiry_Date__c.month();
            }
            
            Decimal fineAmount = 0;
            for(Fines__c fines : mapFineTypes.get(objSR.HexaBPM__Record_Type_Name__c.toLowerCase())){
                if(expiryMonth > 1){
                    fineAmount = fineAmount + fines.First_Month_Amount__c;
                    if(expiryMonth > 2){
                        fineAmount = fineAmount + ((System.Today().month() - 1) * fines.Fine_Amount_Per_Month__c);
                        if(expiryMonth == 12 && (objSR.Entity_PO_Box_Expiry_Date__c.year() + 1) > System.Today().year()){
                            fineAmount = fineAmount + 30;
                        }
                    }
                }
            }
            
            HexaBPM__SR_Price_Item__c objPriceItem = new HexaBPM__SR_Price_Item__c();
            objPriceItem.HexaBPM__ServiceRequest__c = objSR.Id;
            objPriceItem.Entity__c  = objSR.HexaBPM__Customer__c;
            objPriceItem.HexaBPM__Product__c = objPOBoxProduct[0].Id;
            objPriceItem.HexaBPM__Price__c = ADGM_SERVICE_CHARGE_FEE + fineAmount;
            
            objPriceItem.Markup_Amount__c = ADGM_SERVICE_CHARGE_FEE;
            //objPriceItem.Cost__c = 0;
            objPriceItem.Cost__c = fineAmount;
            objPriceItem.Tax_Amount__c = objPriceItem.Markup_Amount__c * 5 / 100;
            
            objPriceItem.HexaBPM__Sys_Added_through_Code__c = true;
            objPriceItem.HexaBPM__Non_Reevaluate__c = true;
            srPriceItemsTBI.add(objPriceItem);

        }
        
        return srPriceItemsTBI;
    }
    public static Decimal getAnnualAmount(Integer startMonth, String bundleType){
        Decimal totalAmount = 0;
        Map<String, PO_Box_Fees__c> poBoxFeesCSMap = new Map<String, PO_Box_Fees__c>();
        for(PO_Box_Fees__c poBoxFee : PO_Box_Fees__c.getAll().values()){
            poBoxFeesCSMap.put(poBoxFee.Name, poBoxFee);
        }
        System.debug('@@POBOC-MAP: '+poBoxFeesCSMap);
        System.debug('@@STARTMONTH: '+startMonth);
        Integer totalMonths = (12 - startMonth) + 1;
        if(poBoxFeesCSMap.get(bundleType)!=null && poBoxFeesCSMap.get(bundleType).Amount_Per_Month__c!=null)
            totalAmount = poBoxFeesCSMap.get(bundleType).Amount_Per_Month__c * totalMonths;
        return totalAmount;
    }
    
    public static String SubmissionAllowed(HexaBPM__Service_Request__c objSR)
    {
        String isAllowed = 'Success';
        /* SubmissionAllowed method is getting called from Custom code as well, so custom code cannot send the entity status field in the objSR variable,
           hence explicitly assigning the Entity stauts field to objSR record to avoid query exception.. */
        if(objSR.HexaBPM__Customer__c != null){
            string eStatus = [Select Entity_Status__c from Account where id=:objSR.HexaBPM__Customer__c].Entity_Status__c ;
            objSR.HexaBPM__Customer__r.Entity_Status__c = eStatus;
        }
        
        set<string> recordtypes= new set<string>{'EChannel_Cancellation','Establishment_Card_Cancellation','P_O_Box_Cancellation','Employment_Visa_Cancellation','Report_Absconding_Employee','Withdraw_Absconding_Status_Employee','Temporary_Work_Permit_Cancellation','Dependent_Visa_Cancellation','Cancel_Full_Time_Non_Sponsored_Employee'};
        if((objSR.HexaBPM__Customer__r.Entity_Status__c == 'Registration Inactive' || objSR.HexaBPM__Customer__r.Entity_Status__c == 'In Liquidation' || 
            objSR.HexaBPM__Customer__r.Entity_Status__c == 'In receivership' || objSR.HexaBPM__Customer__r.Entity_Status__c == 'Deregistered by Registrar'
            || objSR.HexaBPM__Customer__r.Entity_Status__c == 'Inactive') && !recordtypes.contains(objSR.HexaBPM__Record_Type_Name__c))
        {
            isAllowed = 'This service is not available';
            return isAllowed;
        }
        
        if(objSR.HexaBPM__Customer__r.Entity_Status__c == 'Deregistered' || objSR.HexaBPM__Customer__r.Entity_Status__c == 'Dissolved' || 
            objSR.HexaBPM__Customer__r.Entity_Status__c == 'Continued outside ADGM' )
        {
            isAllowed = 'This service is not available';
            return isAllowed;
        }
        Map<String, Duplication_Document_Type_Mapping__c> duplicateMap = new Map<String, Duplication_Document_Type_Mapping__c>();
        for(Duplication_Document_Type_Mapping__c dupMap : Duplication_Document_Type_Mapping__c.getAll().values()){
            duplicateMap.put(dupMap.SR_Record_Type_API__c, dupMap);
        }
        Map<String, Renewal_Days_per_Service_Request_Type__c> priorExpiryMap = new Map<String, Renewal_Days_per_Service_Request_Type__c>();
        for(Renewal_Days_per_Service_Request_Type__c pMap : Renewal_Days_per_Service_Request_Type__c.getAll().values()){
            priorExpiryMap.put(pMap.SR_Recordtype_Name__c, pMap);
        }
        system.debug('$$DUPLICATE_MAP: '+duplicateMap);
        system.debug('$$SR_RecordType: '+objSR.HexaBPM__Record_Type_Name__c);
        if(duplicateMap.containskey(objSR.HexaBPM__Record_Type_Name__c)){
            system.debug('$$SRISNEW: '+duplicateMap.get(objSR.HexaBPM__Record_Type_Name__c).Is_New_SR__c);
            if(duplicateMap.get(objSR.HexaBPM__Record_Type_Name__c).Is_New_SR__c){
                List<Document_Details__c> objDocDetail = [SELECT Id, Document_Type__c, Document_Expiry_Date__c FROM Document_Details__c 
                                                            WHERE Account__c = : objSR.HexaBPM__customer__c 
                                                            AND Document_Type__c = :duplicateMap.get(objSR.HexaBPM__Record_Type_Name__c).Document_Type__c 
                                                            AND Document_Status__c = 'Active' LIMIT 1];
                if(objDocDetail.size()>0){
                    if(objSR.HexaBPM__Record_Type_Name__c != 'Permit_Alcohol' && objSR.HexaBPM__Record_Type_Name__c != 'Permit_Shisha'){
                        isAllowed = duplicateMap.get(objSR.HexaBPM__Record_Type_Name__c).Error_Message__c;
                    } else{
                        if(system.today() < objDocDetail[0].Document_Expiry_Date__c.addDays(-30)){
                            isAllowed = duplicateMap.get(objSR.HexaBPM__Record_Type_Name__c).Error_Message__c;
                        }
                    }
                }
            } else{
                List<Document_Details__c> objDocDetail = [SELECT Id, Document_Type__c, Document_Expiry_Date__c, Document_Status__c FROM Document_Details__c 
                                                            WHERE Account__c = : objSR.HexaBPM__customer__c 
                                                            AND Document_Type__c = :duplicateMap.get(objSR.HexaBPM__Record_Type_Name__c).Document_Type__c];
                System.debug('$$ENTITY: '+objSR.HexaBPM__customer__c);
                System.debug('$$DOCTYPE: '+duplicateMap.get(objSR.HexaBPM__Record_Type_Name__c).Document_Type__c);
                System.debug('$$OBJDOCDETAILS: '+objDocDetail);
                if(objDocDetail.size()==0){
                    isAllowed = duplicateMap.get(objSR.HexaBPM__Record_Type_Name__c).Error_Message__c;
                } else{
                    System.debug('$$OBJDOCDETAILS: '+objDocDetail);
                    for(Document_Details__c objDoc : objDocDetail){
                        if(priorExpiryMap.containskey(objSR.HexaBPM__Record_Type_Name__c)){
                            Decimal expDay = 0;
                            Integer expDayInt = 0;
                            if(priorExpiryMap.get(objSR.HexaBPM__Record_Type_Name__c).Days_Prior_Expiry__c != null){
                                expDay = 0 - priorExpiryMap.get(objSR.HexaBPM__Record_Type_Name__c).Days_Prior_Expiry__c;
                                expDayInt = Integer.valueOf(expDay);
                            }
                            if(system.today() < objDoc.Document_Expiry_Date__c.addDays(expDayInt) && objDoc.Document_Status__c == 'Active'){
                                isAllowed = 'You are not allowed to submit this request. There is still an Active document for this Entity.';
                            }
                        }
                    }
                    
                }
            }
        }
        
        if(objSR.HexaBPM__Record_Type_Name__c == 'Employment_Visa_New' ||
            objSR.HexaBPM__Record_Type_Name__c == 'Employee_Work_Permit_UAE_GCC_National_New' ||
            objSR.HexaBPM__Record_Type_Name__c == 'Temporary_Work_Permit_New' ||
            objSR.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_New'
           /*objSR.HexaBPM__Record_Type_Name__c == 'Visa_Transfer'*/ ){
            if(objSR.Passport_Number__c != null && objSR.Passport_Number__c != ''){
                //List<Contact> objCon = [SELECT Id FROM COntact WHERE Passport_No__c = :objSR.Passport_Number__c];
                List<Contact> objConlst = new List<Contact>();
                string status='Active';
                Search.SearchResults searchList = Search.find('FIND \''+objSR.Passport_Number__c+'\' IN ALL FIELDS RETURNING Contact(Id,Passport_No__c,Name WHERE Dependent_Status__c = :status OR Employment_Status__c =:status)');
                List<Search.SearchResult> contactlist = searchList.get('Contact');
                for(Search.SearchResult searchResult : contactlist){ 
                    Contact objCon = (Contact) searchResult.getSObject(); 
                    if(objCon.Passport_No__c == objSR.Passport_Number__c){
                        System.debug('##TEST1: '+objCon.Id+' : '+objCon.Name);
                        System.debug('##TEST2: '+objCon.Passport_No__c);
                        objConlst.add(objCon);
                    } 
                }

                if(objConlst.size() > 0){
                    isAllowed = 'You are not allowed to submit this request. Applicant is already existing in the system.Applicant with passport number - '+objSR.Passport_Number__c +' is already existing system.';
                }
            }
        }
        
        if(objSR.HexaBPM__Record_Type_Name__c == 'Employment_Visa_Renewal' ||
            objSR.HexaBPM__Record_Type_Name__c == 'Employee_Work_Permit_UAE_GCC_National_Renew' ||
            objSR.HexaBPM__Record_Type_Name__c == 'Temporary_Work_Permit_Renew' ||
            objSR.HexaBPM__Record_Type_Name__c == 'Renew_Work_Permit_Full_Time_Non_Sponsored_Employee' || 
            objSR.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_Renewal'){
            System.debug('@@RENEW: '+objSr.HexaBPM__Contact__c);
            if(objSr.HexaBPM__Contact__c != null){
            
                if(objSr.HexaBPM__customer__c != null){
                    Boolean isCheckRectype = true;
                    if((objSR.HexaBPM__Record_Type_Name__c == 'Temporary_Work_Permit_Renew' && objSR.Temporary_Work_Permit_Type__c == 'Seconded Employee') || objSR.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_Renewal' 
                       || objSR.HexaBPM__Record_Type_Name__c == 'Employment_Visa_Renewal' 
                      || objSR.HexaBPM__Record_Type_Name__c == 'Renew_Work_Permit_Full_Time_Non_Sponsored_Employee')
                    {
                        isCheckRectype = false;
                    }
                    if(isCheckRectype == true){
                        if(ApexCodeUtility.submittedSRS(objSr.HexaBPM__customer__c)==false){
                            isAllowed = 'You have exceeded the total visas allowed for this entity. Kindly contact ADGM Corporate Relations team for more information.';
                        }
                    }
                }
                
                Id contactId = objSR.HexaBPM__Contact__c;
                Boolean isDependentNotFound = false;
                if(objSR.HexaBPM__Record_Type_Name__c == 'Dependent_Visa_Renewal'){
                    contactId = objSR.Dependent__c;
                    Contact dependentContact = new Contact();
                    if(contactId != null){
                        dependentContact = Database.query(queryAllContactFields(contactId));
                    } else{
                        isDependentNotFound = true;
                    }
                    /*dependentContact = Database.query(queryAllContactFields(contactId));
                    if(dependentContact.Dependent_not_found__c == true){
                        isDependentNotFound = true;
                    }*/
                    
                    if(objSR.Passport_Number__c != null && objSR.Passport_Number__c != ''){
                        System.debug('@@PASSPORT');
                        List<Contact> objConlst = new List<Contact>();
                        Search.SearchResults searchList = Search.find('FIND \''+objSR.Passport_Number__c+'\' IN ALL FIELDS RETURNING Contact(Id,Passport_No__c,Name,Recordtype.DeveloperName,AccountId)');
                        List<Search.SearchResult> contactlist = searchList.get('Contact');
                        for(Search.SearchResult searchResult : contactlist){ 
                            Contact objCon = (Contact) searchResult.getSObject(); 
                            if(objCon.Passport_No__c == objSR.Passport_Number__c){
                                objConlst.add(objCon);
                            } 
                        }
                        //List<Contact> objCon = [SELECT Id, AccountId, Recordtype.DeveloperName FROM COntact WHERE Passport_No__c = :objSR.Passport_Number__c];
                        //System.debug('@@OBJCON: '+objCon);
                        if(objConlst.size() > 0){
                            if(objConlst[0].AccountId != objSR.HexaBPM__Customer__c){
                                isAllowed = 'You are not allowed to submit this request. Applicant is already existing in the system.';
                            } else{
                                if(objConlst[0].Recordtype.DeveloperName != 'Contact_Dependent'){
                                    isAllowed = 'You are not allowed to submit this request. Applicant is already existing in the system.';
                                }
                            }
                        }
                    }
                }
            
                if(isDependentNotFound==false){
                    List<Document_Details__c> objDocDetail = [SELECT Id, Document_Type__c, Document_Expiry_Date__c, Document_Status__c FROM Document_Details__c 
                                                                WHERE Contact__c = :contactId  
                                                                AND Document_Type__c = :priorExpiryMap.get(objSR.HexaBPM__Record_Type_Name__c).Document_Type__c LIMIT 1];
                    Decimal expDay = 0;
                    Integer expDayInt = 0;
                    if(priorExpiryMap.get(objSR.HexaBPM__Record_Type_Name__c).Days_Prior_Expiry__c != null){
                        expDay = 0 - priorExpiryMap.get(objSR.HexaBPM__Record_Type_Name__c).Days_Prior_Expiry__c;
                        expDayInt = Integer.valueOf(expDay);
                    }
                    System.debug('@@DOCDETAIL: '+objDocDetail);
                    if(objDocDetail.size() > 0){
                        if(system.today() < objDocDetail[0].Document_Expiry_Date__c.addDays(expDayInt) && objDocDetail[0].Document_Status__c == 'Active'){
                            isAllowed = 'This document is not due for renewal. The expiry date is '+objDocDetail[0].Document_Expiry_Date__c;
                        }
                    }
                }
            }
        }
        
        system.debug('@@ISALLOWED: '+isAllowed);
        return isAllowed;
    }
    
     public static Boolean submittedSRS(Id objAcctId){
        Boolean isAllowed = true;
        Decimal totalSRVisaCount = 0;
        List<Account> objAcct = [SELECT Id, Total_Visas_Allowed__c, Total_Visas_Used__c FROM Account WHERE Id = :objAcctId];
        if(objAcct.size() > 0){
            Decimal totalVisasAllowed = 0;
            if(objAcct[0].Total_Visas_Allowed__c != null){
                totalVisasAllowed = objAcct[0].Total_Visas_Allowed__c;
            }
            totalSRVisaCount = ApexCodeUtility.totalVisaCount(objAcct[0].Id);
            if(totalVisasAllowed <= totalSRVisaCount){
                isAllowed = false;
            }
            System.debug('@@ALLOWEDCTR: '+isAllowed);
        }
        return isAllowed;
    }
    
    public static Decimal totalVisaCount(Id objAcctId){
        Decimal totalSRVisaCount = 0;
        List<Account> objAcct = [SELECT Id, Total_Visas_Allowed__c, Total_Visas_Used__c FROM Account WHERE Id = :objAcctId LIMIT 1];
        Set<String> visaSRSet = new Set<String>{'Employment_Visa_New','Employee_Work_Permit_UAE_GCC_National_New','Temporary_Work_Permit_New'};
        if(objAcct.size() > 0){
            Decimal totalVisasAllowed = 0;
            if(objAcct[0].Total_Visas_Allowed__c != null){
                totalVisasAllowed = objAcct[0].Total_Visas_Allowed__c;
            }
            Decimal totalVisasUsed = 0;
            if(objAcct[0].Total_Visas_Used__c != null){
                totalVisasUsed = objAcct[0].Total_Visas_Used__c;
            }
            Decimal openSrCounter = 0;
            for(HexaBPM__Service_Request__c objSRL : [SELECT Id,Temporary_Work_Permit_Type__c,HexaBPM__Record_Type_Name__c  FROM HexaBPM__Service_Request__c 
                                                                WHERE HexaBPM__customer__c = :objAcctId 
                                                                AND HexaBPM__SR_Template__r.HexaBPM__Sub_menu_section__c = 'Visa Services'
                                                                AND HexaBPM__External_Status_Name__c <> 'Draft' 
                                                                AND HexaBPM__IsCancelled__c <> TRUE 
                                                                AND HexaBPM__Is_Rejected__c <> TRUE
                                                                AND HexaBPM__IsClosedStatus__c <> TRUE
                                                                AND HexaBPM__Record_Type_Name__c IN:visaSRSet]){
                if(!(objSRL.HexaBPM__Record_Type_Name__c == 'Temporary_Work_Permit_New' && objSRL.Temporary_Work_Permit_Type__c == 'Seconded Employee')){
                    openSrCounter = openSrCounter + 1;  
                }            
            }
            System.debug('@@TOTAL_VISA_ALLOWED: '+totalVisasAllowed);
            System.debug('@@TOTAL_VISA_USED: '+totalVisasUsed);
            System.debug('@@TOTAL_OPEN: '+openSrCounter);
            totalSRVisaCount = totalVisasUsed + openSrCounter;
        }
        return totalSRVisaCount;
    }
    
    public static string queryAllContactFields(Id conId){
        String queryStr = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        for(String s : objectFields.keySet()) {
           queryStr += ' ' + s + ', ';
        }
        queryStr = queryStr.subString(0,queryStr.Length()-2);
        queryStr += ' FROM Contact';
        queryStr += ' WHERE Id = \''+conId+'\'';
        
        return queryStr;
    }
    
    public Static String CheckOpenFinePaymentStep(Id objSRId){
        String isAllowed = 'Success';
        
        List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :Userinfo.getUserId()];
        
        if(currentUser!=null && currentUser[0].ContactId!=null){
            List<HexaBPM__Step__c> objActionItems = [SELECT Id FROM HexaBPM__Step__c 
                                                        WHERE HexaBPM__SR__c = :objSRId
                                                        AND HexaBPM__Status__r.HexaBPM__Type__c <> 'End' 
                                                        AND HexaBPM__SR_Step__r.HexaBPM__Step_Template_Code__c = 'PAYMENT_OF_FINES'];
            if(!objActionItems.isEmpty()){
                isAllowed = 'You have an open action item for Fines Payment.';
            }
            system.debug('@@OPENFINE: '+isAllowed);
        }
        return isAllowed;
    }
    
    public static Map<String,Id> getRecTypeDetails(String objAPIName) {
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofLeadRecordTypeDetails = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapofLeadRecordTypeDetails.put(info.getName(),info.getRecordTypeId());
        }    
        return mapofLeadRecordTypeDetails;
    }
    public static Map<Id,String> getRecordTypeDetails(String objAPIName) {
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<Id,String> mapRecordTypeDetails = new Map<Id,String>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapRecordTypeDetails.put(info.getRecordTypeId(),info.getDeveloperName());//
        }    
        return mapRecordTypeDetails;
    }
    //Save payload before callout
    public static API_Payload__c apiPayload{get;set;}

    public static API_Payload__c savePayload(String endPoint,String reqBody, String recordId,String respBody){
        apiPayload = new API_Payload__c();
        try{
            String objectType = (String.isNotEmpty(recordId))?Id.valueOf(recordId).getSobjectType().getDescribe().getName():'';
            if(reqBody != null){
                apiPayload.End_Point__c      = endPoint;
                apiPayload.Payload__c        = reqBody;
                apiPayload.Response__c       = respBody;
                apiPayload.Related_Record__c = recordId;
                apiPayload.Status__c         = 'New';
                if(objectType == 'Receipt__c'){
                    apiPayload.Receipt__c = recordId;
                }else if(objectType == 'Account'){
                    apiPayload.Entity__c = recordId;
                }else if(objectType == 'Invoice__c'){
                    apiPayload.Invoice__c = recordId;
                }else if(objectType == 'Fund_Transfer__c'){
                    apiPayload.Fund_Transfer__c = recordId;
                }
                else if(objectType == 'HexaBPM__Service_Request__c'){
                    apiPayload.Service_Request__c = recordId;
                }
                insert apiPayload;
            }
        }catch(exception e){}
        return apiPayload;
    }
    //----------------------------
}