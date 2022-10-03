/*
 * @Author : Azmath
 * @Description: This class will be used to encode the multipart type of https requests.
*/
public class MultipartHelper 
{
	public static string boundary='------------ADGMBOUNDARY';
    public static String footer = '--'+boundary+'--';
    public static string encodeHeaderKey(string key)
    {
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="'+key+'";\nContent-Type: text/plain';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
           header+=' ';
           headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        return headerEncoded;
    }
    /*
    public static string encodeFileHeaderKey(string key,string filename)
    {
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="'+key+'";filename="'+filename+'";\nContent-Type: application/octet-stream';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
           header+=' ';
           headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        return headerEncoded;
    }*/
    public static string encodeHeaderValue(string value,Blob val)
    {
        String valEncoded;
        if(value == null || value == ''){
            valEncoded = EncodingUtil.base64Encode(val);
        }else{
            valEncoded = EncodingUtil.base64Encode(Blob.valueof(value));
        } 
        String last4Bytes = valEncoded.substring(valEncoded.length()-4,valEncoded.length());
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            valEncoded = valEncoded.substring(0,valEncoded.length()-4) + last4Bytes;
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            valEncoded = valEncoded.substring(0,valEncoded.length()-4) + last4Bytes;
        } 
        return valEncoded;
    }
    
    public static string encodeFooter(){
        string footerval=footer;
        footerval = '\r\n' + footerval;
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footerval));
        return footerEncoded;
    }
}