@isTest
public class TestRetrieveOracleBalance
{
    private static testMethod void RetrieveOracleBalance_UT()
    {
        RetrieveOracleBalance.getOpenReceiptsAmount(null);
        RetrieveOracleBalance.GetOracleBalance('123456');
        RetrieveOracleBalance.getBlockedAmount(null);
        decimal result = RetrieveOracleBalance.getTotalBalance(0.00,0.00,0.00);
        system.assertEquals(0.00,result);
    }

}