@isTest
public class Batch_EntryPermitExpirationAlertsTest
{
    private static testMethod void Batch_EntryPermitExpirationAlerts_UT()
    {
        List<Account> newAccounts = TestClassUtility.createAccounts(1);
        newAccounts[0].Oracle_Party_Id__c = '000001';
        newAccounts[0].License_Expiry_Date__c  = System.today().addYears(1);
        insert newAccounts; 
        
        Contact con = new Contact(LastName='ADGM',Email='test@adgm.com',accountId=newAccounts[0].id);
        insert con;
        
        newAccounts[0].Portal_Lead_Admin__c = con.id;
        update newAccounts;
        
        List<HexaBPM__Service_Request__c> createdSRList = TestUtility.createSR(1,'Employment_Visa_New');
        createdSRList[0].HexaBPM__Customer__c = newAccounts[0].Id;
        createdSRList[0].Entry_Permit_Expiry_Date__c = system.today().addDays(14);
        insert createdSRList;
        
        HexaBPM__Status__c st = new HexaBPM__Status__c(Name=system.label.Entry_Permit_Label,HexaBPM__Code__c='TEST');
        insert st;
        HexaBPM__Step__c step = new HexaBPM__Step__c(HexaBPM__SR__c=createdSRList[0].id,
                                        HexaBPM__Summary__c='Change of Visa Status',
                                        HexaBPM__Status__c=st.id);
        insert step;
        
        Schedule_EntryPermitExpiration batch = new Schedule_EntryPermitExpiration();
        String sch = '0 0 23 * * ?';
        system.schedule('Reminder Notification', sch, batch);
        
        database.executeBatch(new Batch_EntryPermitExpirationAlerts(),50);
    }
}