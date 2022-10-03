/*
    Author      : Kim Noceda
    Date        : 22-Mar-2018
    Description : Controller class to create an appointment on the portal from the Step
    --------------------------------------------------------------------------------------
*/
public class BookAppointmentController{

    public string srId {get;set;}
    
    public BookAppointmentController(){
        String strId = Apexpages.currentpage().getparameters().get('id');
        srId = '';
        if(strId != null){
           srId =  strId;
        }
    }
}