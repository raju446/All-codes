public class ContactAndLeadSearch{

public static list<list<SObject>> searchContactsAndLeads(String LastName){
 List<List<SObject>> searchList = [FIND 'Smith' IN ALL FIELDS RETURNING Lead (LastName), Contact(LastName)];
            return searchList;
          }
}