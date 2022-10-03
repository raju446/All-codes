/****************************
Author : Azmath
Created Date: 02/05/2018
Description : Test Class for WS_CreateCatalystEntity.
Modification History: 
****************************** */
@isTest
public class WS_CreateCatalystEntityTest
{
    private static testMethod void WS_CreateCatalystEntity_UT()
    {
    
        WS_CreateCatalystEntity.EntityInformation entity = new WS_CreateCatalystEntity.EntityInformation();
        entity.EntityId                 = '8273456789';
        entity.EntityLicenseCategory    = 'Sample Category';
        entity.EntityName               = 'Injazat Middle East-2';
        entity.EntityNameArabic         = 'Injazat Middle East-2';
        entity.EntitySubType            = 'SPV';
        entity.EntityType               = 'Public Company Limited By Shares';
        entity.ExpiryDate               = '2020-01-20';
        entity.RegistrationDate         = '2020-01-01';
        entity.RegistrationStatus       = 'Active';
        entity.IsCIDApproval            = true;
        entity.TotalAuthorisedSignatories = 2;
        
        //Invoke Business Activity Validation    
        WS_CreateCatalystEntity.ProcessEntity(entity);
        
        //Skip BA validation by passing BA information.
        WS_CreateCatalystEntity.BusinessActivitiy  bActivity = new WS_CreateCatalystEntity.BusinessActivitiy();
        bActivity.ActivityName          = 'General Trading';
        bActivity.ActivityNameArabic    = 'General Trading';
        bActivity.Description           = 'General Trading';
        bActivity.DescriptionArabic     = 'General Trading';
        bActivity.Type                  = 'Test';
        bActivity.ActivityCode          = '106536';
        bActivity.Section               = 'Test';
        
        entity.BusinessActivities.add(bActivity);
        WS_CreateCatalystEntity.ProcessEntity(entity);
        
        //Skip PA validation by passing PA information.
        WS_CreateCatalystEntity.Address address = new WS_CreateCatalystEntity.Address();
        address.BuildingName    = 'SABA-3';
        address.Country         = 'United Arab Emirates';
        address.Emirates        = 'Dubai';
        address.Floor           = '33';
        address.OfficeNumber    = '3302';
        address.State           = 'Dubai';
        address.StreetName      = 'JLT';
        
        entity.PhysicalAddress = address;
        WS_CreateCatalystEntity.ProcessEntity(entity);

        
        entity.PostalAddress = address;
        WS_CreateCatalystEntity.ProcessEntity(entity);
        
        entity.IsCIDApproval    = false;
        entity.RegistrationDate = null;
        WS_CreateCatalystEntity.ProcessEntity(entity);
        
        entity.RegistrationDate = '2020-01-01';
        entity.ExpiryDate = null;
        WS_CreateCatalystEntity.ProcessEntity(entity);
        
        entity.ExpiryDate = '2020-01-20';
        WS_CreateCatalystEntity.ProcessEntity(entity);
        
        WS_CreateCatalystEntity.Document doc = new WS_CreateCatalystEntity.Document();
        doc.FileName = 'Commercial License';
        doc.ContentType = 'image/jpeg';
        doc.FileBody = 'jaljdsfksjfdjtiueowrjljfljsfd';
        doc.FileId = '1234';
        
        WS_CreateCatalystEntity.TradeName trade = new WS_CreateCatalystEntity.TradeName();
        trade.TradeName = 'Injazat Middle East';
        trade.TradeNameArabic = 'Injazat Middle East';
        entity.TradeNames.add(trade);
        
        entity.CommercialLicense = doc;
        WS_CreateCatalystEntity.ProcessEntity(entity);
        
    }

}