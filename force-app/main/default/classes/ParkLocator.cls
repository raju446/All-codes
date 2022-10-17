public class ParkLocator {
    public static String[] country(String country){
      parksServices.ParksImplPort parks = new parksServices.ParksImplPort();
        String[] parksname = parks.byCountry(country);
        return parksname;
    }
}