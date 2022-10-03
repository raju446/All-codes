@isTest
public class WelcomeTextHelperTest
{
    public static testMethod void WelcomeTextHelper()
    {
        WelcomeTextHelper wh = new WelcomeTextHelper();
        wh.UId = UserInfo.getUserId();
        wh.getwelcomeText();
    }
}