public class ParkLocator {
    public static String[] country(String Countries){
        ParkService.ParksImplPort parkSvc = new ParkService.ParksImplPort();
        return parkSvc.byCountry(Countries);
    }
}