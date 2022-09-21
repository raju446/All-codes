public class ContactSearch {
    public static list<contact> searchForContacts(string lastname,string MailingPostalCode)
    { 
list<contact> ContactList=[select id,name,lastname,mailingpostalcode from contact where lastname=:'lastname' and mailingpostalcode=:'MailingPostalcode'];
        return contactlist;
    }
}