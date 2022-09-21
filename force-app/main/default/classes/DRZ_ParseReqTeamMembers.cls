public class DRZ_ParseReqTeamMembers {
	public String OpportunityId;
    public String TransactionId;//part DRZ ID that they can trace in app insights
	public List<TeamMembers> TeamMembers;

	public class TeamMembers {
		public String UserId;
		public String Operation;
	}

	
	public static DRZ_ParseReqTeamMembers parse(String json) {
		return (DRZ_ParseReqTeamMembers) System.JSON.deserialize(json, DRZ_ParseReqTeamMembers.class);
	}
}