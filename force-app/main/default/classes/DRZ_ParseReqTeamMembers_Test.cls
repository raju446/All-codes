@isTest
public class DRZ_ParseReqTeamMembers_Test{
    
    public static void parasemetho(){
         Opportunity acc= new Opportunity();
		 String UserId;
		 String Operation;
	}

	
	public static DRZ_ParseReqTeamMembers parse(String json) {
		return (DRZ_ParseReqTeamMembers) System.JSON.deserialize(json, DRZ_ParseReqTeamMembers.class);
        
    }
}