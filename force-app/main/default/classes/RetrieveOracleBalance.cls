/***************************
Author : Azmath
Description : This class will be used to display the Oracle
              balance when user clicks on Check Customer Balance
              from Entity detail page.
***************************** */

global without sharing class RetrieveOracleBalance
{
    webservice static decimal getOpenReceiptsAmount(Id accountid)
    {
        return ApexCodeUtility.getOpenReceiptsAmount(accountid);
    }
    webservice static decimal GetOracleBalance(string partyId)
    {
        return WS_BalanceCheck.GetOracleBalance(partyId);
    }
    webservice static decimal getBlockedAmount(Id accountid)
    {
        return ApexCodeUtility.getBlockedAmount(accountid);
    }
    webservice static decimal getTotalBalance(decimal ReceiptsAmount, decimal oracleBalance, decimal BlockedSRsAmount)
    {
        return ((ReceiptsAmount + oracleBalance) - BlockedSRsAmount).setscale(2);
    }
}