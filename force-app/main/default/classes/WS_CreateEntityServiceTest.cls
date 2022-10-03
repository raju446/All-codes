@isTest
public class WS_CreateEntityServiceTest {
    public static testmethod void test1(){
        WS_CreateEntityService.EntityInformation wrapperObj = new WS_CreateEntityService.EntityInformation();
		WS_CreateEntityService.ProcessEntity(wrapperObj);  
        
        wrapperObj.EntityId = 'test1';
        wrapperObj.EntityName = 'Test First Last';
        wrapperObj.EntityNameArabic = 'test';
        wrapperObj.SourceSystemName = 'RA';
        wrapperObj.EntityType = 'ET';

        WS_CreateEntityService.ProcessEntity(wrapperObj);
        
        wrapperObj.SourceSystemName = 'RAAAA';
        WS_CreateEntityService.ProcessEntity(wrapperObj);
        
        wrapperObj.SourceSystemName = 'RAAAA';
        WS_CreateEntityService.ProcessEntity(wrapperObj);
        
        wrapperObj.Address_Line1 = 'Dubai';
        wrapperObj.SourceSystemName = 'Catalyst';
        wrapperObj.Recordtype_DeveloperName = 'ADGM_Registered_Company';
        wrapperObj.Country = 'United Arab Emirates';
        
        WS_CreateEntityService.ProcessEntity(wrapperObj);
    }
    public static testmethod void test2(){
        WS_CreateEntityService.EntityInformation wrapperObj = new WS_CreateEntityService.EntityInformation();
		WS_CreateEntityService.ProcessEntity(wrapperObj);  
        
        wrapperObj.EntityId = 'test1';
        wrapperObj.EntityName = 'Test First Last';
        wrapperObj.EntityNameArabic = 'test';
        wrapperObj.SourceSystemName = 'RA';
        wrapperObj.EntityType = 'ET';

        WS_CreateEntityService.ProcessEntity(wrapperObj);
        
        wrapperObj.SourceSystemName = 'RAAAA';
        WS_CreateEntityService.ProcessEntity(wrapperObj);
        
        wrapperObj.SourceSystemName = 'RAAAA';
        WS_CreateEntityService.ProcessEntity(wrapperObj);
        
        wrapperObj.Address_Line1 = 'Dubai';
        wrapperObj.SourceSystemName = 'Catalyst';
        wrapperObj.Recordtype_DeveloperName = 'ADGM_Registered_Company';
        wrapperObj.Country = 'United Arab Emirates';
        
        wrapperObj.PersonFirstName = 'Test First';
        wrapperObj.PersonLastName = 'Last';
        
        WS_CreateEntityService.ProcessEntity(wrapperObj);
    }
}