public class TestHelper {

	public static boolean calloutTest = false;	
	
	public static boolean allowCallout() {

		if (Test.isRunningTest() && !calloutTest){
			return false;
		} else {
			return true;
		}

	}

}