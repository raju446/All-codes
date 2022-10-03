/*
    Author      :   Yogesh Mahajan 
    Class Name  :   TranslateAPI
    Description :   It is used as a wrapper for google translate
    Date        :   02/20/2019
*/
public class TranslateAPI {
    public Data data;
    public class Data {
        public List<Translations> translations;
    }
    public class Translations {
        public String translatedText;
    }
    public static TranslateAPI parse(String json) {
        return (TranslateAPI) System.JSON.deserialize(json, TranslateAPI.class);
    }
}