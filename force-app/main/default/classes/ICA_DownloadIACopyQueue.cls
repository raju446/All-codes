public without sharing class ICA_DownloadIACopyQueue implements Queueable, Database.AllowsCallouts
{
    public Id srId;
    public ICA_DownloadIACopyQueue(Id sid)
    {
        this.srId = sid;
    }
    public void execute(QueueableContext context)
    {
        ICA_EstablishmentCardUtil.invokePrintIACopyapi(srId);
    }
}