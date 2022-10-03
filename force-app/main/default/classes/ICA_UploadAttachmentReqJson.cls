public without sharing class ICA_UploadAttachmentReqJson 
{
    public ICA_UploadAttachmentReqJson(string fname, string mimetype, string fid, string name, string dno, string base64)
    {
        UD_Input = new UD_Input(fname, mimetype, fid, name, dno, base64);
    }
    public UD_Input UD_Input;

    public class UD_Input {
        public String originalFileName;
        public String attachmentFileMIMEType;
        public string attachmentTypeId;
        public String name;
        public String draftNumber;
        public String attachmentFile;
        public UD_Input(string fname, string mimetype, string fid, string name, string dno, string base64)
        {
            this.originalFileName       = name;
            this.attachmentFileMIMEType = mimetype;
            this.attachmentTypeId       = fid;
            this.name                   = fname;//
            this.draftNumber            = dno;
            this.attachmentFile         = base64;
        }
    }
}