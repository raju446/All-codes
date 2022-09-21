public class studentsinsert {
     public static void insertstudents(){
        List<student2__c> stlist = new List<student2__c>();
         List<string> strlist = new List<string>{'mahendra1','sonalika1'};
         for(string st:strlist){
             student2__c s1 = new student2__c();
                         s1.name =st;
                         s1.gender__c ='male';
                      s1.teacher2__c = 'a0B5g000004Y4NJEA0';
                      stlist.Add(s1);
         system.debug('studentlist===='+stlist);
    }
         insert stlist;
     }              
}