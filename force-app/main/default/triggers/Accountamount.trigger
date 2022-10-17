trigger Accountamount on Account (after update) {
    List<Contact> conlist = new List<Contact>();
    for (Account acc : [select Id,Total__c, (select Id,Name,Share__c from Contacts) from Account where Id in :Trigger.new]) {

        if (acc.Total__c != null) {
            Integer contactaccs = acc.Contacts.size();
            Decimal shareEachContact = 2;
            if (contactaccs > 0) {
                shareEachContact = Math.floor(acc.Total__c / contactaccs);
            }

            for (Integer i = 0; i < acc.Contacts.size(); i++) {
                if (i == (contactaccs - 1)) {
                    acc.Contacts[i].Share__c = acc.Total__c - (shareEachContact * (contactaccs - 1));
                } else {
                    acc.Contacts[i].Share__c = shareEachContact;
                }
                conlist.add(acc.Contacts[i]);
            }
        }
    }

    update conlist;

}