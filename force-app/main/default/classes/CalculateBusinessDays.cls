/*
    Author      : Prachi Sinha
    Date        : 31-03-2021
    Description : Class to calculate the business days based on the configured business hours in the org
    --------------------------------------------------------------------------
*/
public without sharing class CalculateBusinessDays {

    public static Datetime addDays(Datetime dSartDate, Integer iDays, Id bHoursId){        
        dSartDate = BusinessHours.nextStartDate(bHoursId, dSartDate);  
        for (Integer i = 0; i < iDays; i++){         
            dSartDate = dSartDate.addDays(1);               
            if (!BusinessHours.isWithin(bHoursId, dSartDate)){                
                dSartDate = BusinessHours.nextStartDate(bHoursId, dSartDate);
            }
        }
        return dSartDate;
    }    

}