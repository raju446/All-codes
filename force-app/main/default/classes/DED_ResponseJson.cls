public without sharing class DED_ResponseJson 
{
    public class RenewBLFZEDResult {
		public String CBLSSubmissionID;
		public String FCRNumber;
		public Message message;
	}
	public class IssueBLFZEDResult {
		public String CBLSSubmissionID;
		public String FCRNumber;
		public Message message;
	}
	public class ModifyBLFZEDResult {
		public String CBLSSubmissionID;
		public String FCRNumber;
		public Message message;
	}
	public class CancelBLFZEDResult {
		public String CBLSSubmissionID;
		public String FCRNumber;
		public Message message;
	}
	public UD_Output UD_Output;

	public class Message {
		public List<CBLSResponseMessage> CBLSResponseMessage;
	}

	public class CBLSResponseMessage {
		public Double MessageCode;
		public String MessageTextAR;
		public String MessageTextEN;
		public Double MessageType;
	}

	public class UD_Output {
		public IssueBLFZEDResult issueBLFZEDResult;
		public RenewBLFZEDResult renewBLFZEDResult;
		public ModifyBLFZEDResult modifyBLFZEDResult;
		public CancelBLFZEDResult CancelBLFZEDResult;
	}
}