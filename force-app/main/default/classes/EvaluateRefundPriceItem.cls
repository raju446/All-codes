/*
    Author      : Durga Prasad
    Date        : 01-Nov-2018
    Description : Apex Class to evaluate the Refund SRPriceItem while SR is Rejected
    --------------------------------------------------------------------------------------
*/
public without sharing class EvaluateRefundPriceItem {
    public static void CreateRefundLine(HexaBPM__Step__c stp){
        if(stp!=null && stp.Id!=null){
        HexaBPM__SR_Price_Item__c SRP;
        boolean FullRefund = false;
        
        decimal RefundTotalAmount = 0;
      decimal RefundMarkup = 0;
      decimal RefundCost = 0;
      decimal RefundVAT = 0;
      decimal RefundCancellationFee = 0;
        
        for(HexaBPM__Step__c step:[Select Id,HexaBPM__SR__c,HexaBPM__SR__r.Person_In_UAE__c,HexaBPM__SR__r.Age_Days__c,HexaBPM__SR_Step__c,HexaBPM__SR_Step__r.Full_Refund__c,HexaBPM__SR_Step__r.Refund_Amount_Inside_UAE__c,
        HexaBPM__SR_Step__r.Refund_Cost_Inside_UAE__c,HexaBPM__SR_Step__r.Refund_Markup_Inside_UAE__c,HexaBPM__SR_Step__r.Refund_VAT_Inside_UAE__c,
        HexaBPM__SR_Step__r.Refund_Amount_Outside_UAE__c,HexaBPM__SR_Step__r.Refund_Cost_Outside_UAE__c,HexaBPM__SR_Step__r.Refund_Markup_Outside_UAE__c,HexaBPM__SR_Step__r.Refund_VAT_Outside_UAE__c,
       HexaBPM__SR_Step__r.Age_Factor_18__c, HexaBPM__SR_Step__r.Refund_Cost_Inside_UAE_Below_18__c, HexaBPM__SR_Step__r.Refund_Cost_Outside_UAE_Below_18__c, HexaBPM__SR_Step__r.Refund_Amount_Inside_UAE_Below_18__c,
        HexaBPM__SR_Step__r.Refund_Fee_Outside_UAE_Below_18__c, HexaBPM__SR_Step__r.Refund_Markup_Inside_UAE_Below_18__c, HexaBPM__SR_Step__r.Refund_Markup_Outside_UAE_Below_18__c, 
         HexaBPM__SR_Step__r.Refund_VAT_Inside_UAE_Below_18__c, HexaBPM__SR_Step__r.Refund_VAT_Outside_UAE_Below_18__c,HexaBPM__SR__r.Visa_Period__c  from HexaBPM__Step__c where Id=:stp.Id]){
          if(step.HexaBPM__SR_Step__r.Full_Refund__c){
            FullRefund = true;
          }else if(step.HexaBPM__SR__r.Person_In_UAE__c!=null && step.HexaBPM__SR_Step__c!=null && (step.HexaBPM__SR_Step__r.Refund_Amount_Inside_UAE__c!=null || step.HexaBPM__SR_Step__r.Refund_Amount_Outside_UAE__c!=null)){
            SRP = new HexaBPM__SR_Price_Item__c();
            SRP.HexaBPM__ServiceRequest__c = step.HexaBPM__SR__c;
            SRP.HexaBPM__Status__c = 'Blocked';
            if(step.HexaBPM__SR__r.Person_In_UAE__c=='Yes'){ //Inside UAE - Refund values..
            if(step.HexaBPM__SR_Step__r.Age_Factor_18__c == false || 
              (step.HexaBPM__SR_Step__r.Age_Factor_18__c && step.HexaBPM__SR__r.Age_Days__c != null && step.HexaBPM__SR__r.Age_Days__c > 18)){
              if(step.HexaBPM__SR_Step__r.Refund_Amount_Inside_UAE__c!=null)
                RefundTotalAmount = RefundTotalAmount + step.HexaBPM__SR_Step__r.Refund_Amount_Inside_UAE__c;
              if(step.HexaBPM__SR_Step__r.Refund_Cost_Inside_UAE__c!=null)
                RefundCost = RefundCost + step.HexaBPM__SR_Step__r.Refund_Cost_Inside_UAE__c;
              if(step.HexaBPM__SR_Step__r.Refund_Markup_Inside_UAE__c!=null)
                RefundMarkup = RefundMarkup + step.HexaBPM__SR_Step__r.Refund_Markup_Inside_UAE__c;
              if(step.HexaBPM__SR_Step__r.Refund_VAT_Inside_UAE__c!=null)
                RefundVAT = RefundVAT + step.HexaBPM__SR_Step__r.Refund_VAT_Inside_UAE__c;
                
                if(step.HexaBPM__SR__r.Visa_Period__c == '1')
                {
                    RefundCost = 1510.55;
                    RefundMarkup = 639.45;
                    RefundVAT = 31.97;
                    RefundTotalAmount = RefundCost + RefundMarkup;
                }
            }
            else if (step.HexaBPM__SR_Step__r.Age_Factor_18__c && step.HexaBPM__SR__r.Age_Days__c != null && step.HexaBPM__SR__r.Age_Days__c < 18){
              if(step.HexaBPM__SR_Step__r.Refund_Amount_Inside_UAE_Below_18__c!=null)
                RefundTotalAmount = RefundTotalAmount + step.HexaBPM__SR_Step__r.Refund_Amount_Inside_UAE_Below_18__c;
              if(step.HexaBPM__SR_Step__r.Refund_Cost_Inside_UAE_Below_18__c!=null)
                RefundCost = RefundCost + step.HexaBPM__SR_Step__r.Refund_Cost_Inside_UAE_Below_18__c;
              if(step.HexaBPM__SR_Step__r.Refund_Markup_Inside_UAE_Below_18__c!=null)
                RefundMarkup = RefundMarkup + step.HexaBPM__SR_Step__r.Refund_Markup_Inside_UAE_Below_18__c;
              if(step.HexaBPM__SR_Step__r.Refund_VAT_Inside_UAE_Below_18__c!=null)
                RefundVAT = RefundVAT + step.HexaBPM__SR_Step__r.Refund_VAT_Inside_UAE_Below_18__c;
            }
            }else{ //Outside UAE - Refund values
            if(step.HexaBPM__SR_Step__r.Age_Factor_18__c == false || 
              (step.HexaBPM__SR_Step__r.Age_Factor_18__c && step.HexaBPM__SR__r.Age_Days__c != null && step.HexaBPM__SR__r.Age_Days__c > 18)){
              if(step.HexaBPM__SR_Step__r.Refund_Amount_Outside_UAE__c!=null)
                RefundTotalAmount = RefundTotalAmount + step.HexaBPM__SR_Step__r.Refund_Amount_Outside_UAE__c;
              if(step.HexaBPM__SR_Step__r.Refund_Cost_Outside_UAE__c!=null)
                RefundCost = RefundCost + step.HexaBPM__SR_Step__r.Refund_Cost_Outside_UAE__c;
              if(step.HexaBPM__SR_Step__r.Refund_Markup_Outside_UAE__c!=null)
                RefundMarkup = RefundMarkup + step.HexaBPM__SR_Step__r.Refund_Markup_Outside_UAE__c;
              if(step.HexaBPM__SR_Step__r.Refund_VAT_Outside_UAE__c!=null)
                RefundVAT = RefundVAT + step.HexaBPM__SR_Step__r.Refund_VAT_Outside_UAE__c;
                
                if(step.HexaBPM__SR__r.Visa_Period__c == '1')
                {
                    RefundCost = 957.55;
                    RefundMarkup = 392.45;
                    RefundVAT = 19.62;
                    RefundTotalAmount = RefundCost + RefundMarkup;
                }
            }
            else if (step.HexaBPM__SR_Step__r.Age_Factor_18__c && step.HexaBPM__SR__r.Age_Days__c != null && step.HexaBPM__SR__r.Age_Days__c < 18){
              if(step.HexaBPM__SR_Step__r.Refund_Fee_Outside_UAE_Below_18__c!=null)
                RefundTotalAmount = RefundTotalAmount + step.HexaBPM__SR_Step__r.Refund_Fee_Outside_UAE_Below_18__c;
              if(step.HexaBPM__SR_Step__r.Refund_Cost_Outside_UAE_Below_18__c!=null)
                RefundCost = RefundCost + step.HexaBPM__SR_Step__r.Refund_Cost_Outside_UAE_Below_18__c;
              if(step.HexaBPM__SR_Step__r.Refund_Markup_Outside_UAE_Below_18__c!=null)
                RefundMarkup = RefundMarkup + step.HexaBPM__SR_Step__r.Refund_Markup_Outside_UAE_Below_18__c;
              if(step.HexaBPM__SR_Step__r.Refund_VAT_Outside_UAE_Below_18__c!=null)
                RefundVAT = RefundVAT + step.HexaBPM__SR_Step__r.Refund_VAT_Outside_UAE_Below_18__c;
            }
            }
            SRP.Cancellation_Fee__c = 0;
          }
        }
        
        if(FullRefund){
          for(HexaBPM__SR_Price_Item__c PI:[Select Id,Markup_Amount__c,Cost__c,Tax_Amount__c,Cancellation_Fee__c,Total_Amount__c from HexaBPM__SR_Price_Item__c where HexaBPM__ServiceRequest__c=:stp.HexaBPM__SR__c]){
            if(PI.Markup_Amount__c != null)
                RefundTotalAmount = RefundTotalAmount + PI.Markup_Amount__c;
            
            if(PI.Cost__c != null)
                RefundTotalAmount = RefundTotalAmount + PI.Cost__c;
            
            //if(PI.Total_Amount__c!=null)
              //RefundTotalAmount = RefundTotalAmount + PI.Total_Amount__c;
            if(PI.Markup_Amount__c!=null)
              RefundMarkup = RefundMarkup + PI.Markup_Amount__c;
          if(PI.Cost__c!=null)
              RefundCost = RefundCost+PI.Cost__c;
            if(PI.Tax_Amount__c!=null)
              RefundVAT = RefundVAT + PI.Tax_Amount__c;
            if(PI.Cancellation_Fee__c!=null)
              RefundCancellationFee = RefundCancellationFee + PI.Cancellation_Fee__c;           
          }
        }
        system.debug('RefundTotalAmount==>'+RefundTotalAmount);
      system.debug('RefundMarkup==>'+RefundMarkup);
      system.debug('RefundCost==>'+RefundCost);
      system.debug('RefundVAT==>'+RefundVAT);
      system.debug('RefundCancellationFee==>'+RefundCancellationFee);
        if(RefundTotalAmount>0){
        SRP = new HexaBPM__SR_Price_Item__c(HexaBPM__ServiceRequest__c=stp.HexaBPM__SR__c,Markup_Amount__c=RefundMarkup*-1,Cost__c=RefundCost*-1,Tax_Amount__c=RefundVAT*-1,HexaBPM__Price__c=RefundTotalAmount*-1,Cancellation_Fee__c=RefundCancellationFee*-1);
          for(Product2 pd:[select Id from Product2 where productcode='REFUND']){
            SRP.HexaBPM__Product__c = pd.Id;
            SRP.HexaBPM__Non_Reevaluate__c = true;
            SRP.HexaBPM__Sys_Added_through_Code__c = true;
            SRP.Is_Refund_Line__c = true;
          }
          insert SRP;
        }
      }
    }
}