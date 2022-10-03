public without sharing class ICADocumentTriggeHandler 
{
    public static void before_Insert(list<ICA_Document__c> triggerNew)
    {
        for(ICA_Document__c icadoc : triggerNew)
        {
        	if(icadoc.Attachment_Type_Text__c == 'COPY OF RESIDENCY')
            	icadoc.Description__c = 'Visa copy for external Authorised signatories';
            else if (icadoc.Attachment_Type_Text__c.contains('AMIRI DECREE')){
            	icadoc.Description__c = 'Initial approval copy';
            	icadoc.Is_Attachment_Mandatory__c= true;
            }
            else if (icadoc.Attachment_Type_Text__c.contains('TRADE LICENSE')){
            	icadoc.Description__c = 'Commercial license copy';
            	icadoc.Is_Attachment_Mandatory__c= true;
            }
            
            if(icadoc.SR_Record_Type__c == 'Initial_Approval')
            {
                if(icadoc.Attachment_Type_Text__c == 'EXCEPTIONAL ATTACHMENT NO 1')
                {
                	icadoc.Description__c = 'External Auth. Sig PP copy & EID';
                    icadoc.Is_Attachment_Mandatory__c= true;
                }
                else if(icadoc.Attachment_Type_Text__c == 'EXCEPTIONAL ATTACHMENT NO 2'){
                	icadoc.Description__c = 'Letter from ADGM';
                	icadoc.Is_Attachment_Mandatory__c= true;
                }
            }
            else if(icadoc.SR_Record_Type__c == 'Establishment_Card_New')
            {
            	 if(icadoc.Attachment_Type_Text__c == 'COPY OF THE AUTHORIZATION FOR THE AUTHORIZED SIGNATORIES')
            		icadoc.Description__c = 'ADGM Authority - Establishment card copy';
            		
            	 else if(icadoc.Attachment_Type_Text__c == 'A COPY OF THE INVESTOR OR PARTNER\'S PASSPORT')
            	 {
            	 	icadoc.Is_Attachment_Mandatory__c= true;
            	 	icadoc.Description__c = 'Internal Authorised signatories passport copies';
            	 }
            	 else if(icadoc.Attachment_Type_Text__c == 'EXCEPTIONAL ATTACHMENT NO 1')
            	 {
            	 	icadoc.Is_Attachment_Mandatory__c= true;
            	 	icadoc.Description__c = 'Commercial license copy';
            	 }
            	 else if(icadoc.Attachment_Type_Text__c == 'EXCEPTIONAL ATTACHMENT NO 2')
            	 {
            	 	icadoc.Is_Attachment_Mandatory__c= true;
            	 	icadoc.Description__c = 'Passport copy of the external ';
            	 }
            }
            else if(icadoc.SR_Record_Type__c == 'Establishment_Card_Renewal')
            {
                if(icadoc.Attachment_Type_Text__c == 'ORIGINAL AUTHORIZATION FOR THE AUTHORIZED SIGNATORIES'){
                    icadoc.Is_Attachment_Mandatory__c= true;
                    icadoc.Description__c = 'ADGM Authority - Establishment card copy';
                }
                else if(icadoc.Attachment_Type_Text__c == 'A COPY OF THE INVESTOR OR PARTNER\'S PASSPORT'){
                	icadoc.Is_Attachment_Mandatory__c= true;
                    icadoc.Description__c = 'Internal Authorised signatories passport copies';
                }
                else if(icadoc.Attachment_Type_Text__c == 'EXCEPTIONAL ATTACHMENT NO 1'){
                	icadoc.Is_Attachment_Mandatory__c= true;
                    icadoc.Description__c = 'Copy of the previous establishment card';
                }
                else if(icadoc.Attachment_Type_Text__c == 'EXCEPTIONAL ATTACHMENT NO 2'){
                	icadoc.Is_Attachment_Mandatory__c= true;
                    icadoc.Description__c = 'Commercial license copy';
                }
                /*else if(icadoc.Attachment_Type_Text__c == 'COPY OF THE AMIRI DECREE OR THE MINISTERIAL DECREES FOR ESTABLISHING THE ESTABLISHMENT'){
                    icadoc.Description__c = 'ADGM Authority - Establishment card copy';
                }*/
                if (icadoc.Attachment_Type_Text__c.contains('AMIRI DECREE')){
	            	icadoc.Description__c = 'ADGM Authority - Establishment card copy';
            	}
            }
            else if(icadoc.SR_Record_Type__c == 'Establishment_Card_Amendment')
            {
            	if(icadoc.Attachment_Type_Text__c.trim() == 'A COPY OF THE INVESTOR OR PARTNER\'S PASSPORT AND A COPY OF THE RESIDENCE'){
                    icadoc.Is_Attachment_Mandatory__c= true;
                    icadoc.Description__c = 'Internal Authorised signatories passport copies';
                }
                else if(icadoc.Attachment_Type_Text__c.trim() == 'ORIGINAL AUTHORIZATION FOR THE AUTHORIZED SIGNATORIES WITH THE ORIGINAL'){
                    icadoc.Is_Attachment_Mandatory__c= true;
                    icadoc.Description__c = 'ADGM Authority - Establishment card copy';
                }
            }
            else if(icadoc.SR_Record_Type__c == 'Establishment_Card_Cancellation')
            {
                if(icadoc.Attachment_Type_Text__c == 'OFFICIAL LETTER FROM THE MUNICIPALITY AND MINISTRY OF LABOUR STATING THE REVOCATION OF THE LICENSE'){
                    icadoc.Is_Attachment_Mandatory__c= true;
                    icadoc.Description__c = 'Letter from ADGM';
                }
            }
        }
    }
}