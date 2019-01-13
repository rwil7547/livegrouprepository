public with sharing class OppEmailController {
    
    public Id opportunityId {get;set;}
    public Opportunity opp {get; set;}    
    private List<Opportunity> relevantOpps;
    private List<Roadshow_Event__c> relevantShows;
    private List<event> events;
    private Integer recordCount;
    private Date startDate;
    private Date endDate;
    private String location;    

    public void getDataSetup() {

        events = new List<event>();
        recordCount = 0;
		
		opp = [SELECT Id, Event_start__c, Event_end__c,Filtered_Account_Name__c,
                      Event_Month_Text__c,AccountId, Name, 
					  Filtered_Job_Number__c, Location__c, 
                      Amount_Calder__c, Primary_Service__c
			   FROM Opportunity
               WHERE Id = :opportunityId LIMIT 1];

        startDate = opp.Event_start__c;
        endDate = opp.Event_end__c;
        location = (opp.Location__c == null) ? ' (location TBC)' : ' in ' + opp.Location__c;

        relevantOpps = [SELECT Name, Account.Name, Filtered_Job_Number__c, 
                                Location__c, Venue__c, Project_Manager__r.Name
                         FROM Opportunity 
                         WHERE Id != :opportunityId
                         AND StageName = 'Closed Won'
                         AND Exclude_from_project_tracker2__c != 'Yes'
                         AND Event_start__c <=: endDate
                         AND Event_end__c >=: startDate];

        for (Opportunity o : relevantOpps){
            event e = new event(
                o.Name, 
                o.Account.Name, 
                o.Filtered_Job_Number__c,
                o.Location__c,
                o.Venue__c, 
                o.Project_Manager__r.Name);
            events.add(e);
            recordCount++;
        }

        relevantShows = [SELECT Name, Account__c, Job_Number__c, 
                                Location__c, Venue__c, Project_Manager__c
                         FROM Roadshow_Event__c
                         WHERE Stage__c = 'Closed Won'
                         AND Exclude_from_project_tracker__c != 'Yes'
                         AND Event_start__c <=: endDate
                         AND Event_end__c >=: startDate];                        
 
        for (Roadshow_Event__c r : relevantShows){
            event e = new event(
                r.Name, 
                r.Account__c, 
                r.Job_Number__c,
                r.Location__c,
                r.Venue__c, 
                r.Project_Manager__c);
            events.add(e);
            recordCount++;            
        }


    }  
    
    public string getCount() {

        String dateRange = (startDate == endDate) ? 'this date' : 'these dates';
        String oppsAmount = (recordCount > 0) ? String.valueOf(recordCount) : 'no';
        String response;
        
        if (recordCount == 0) {
            response = 'There are currently ' + oppsAmount + 
            ' other confirmed events taking place on ' + 
            dateRange + '.';         
        } else if (recordCount == 1) {
            response = 'There is currently ' + oppsAmount + 
            ' other confirmed event taking place on ' + 
            dateRange + ':'; 
        } else {
            response = 'There are currently ' + oppsAmount + 
            ' other confirmed events taking place on ' + 
            dateRange + ':';
        }
        
        return response;
        
    }

    public String getDates() {
    	if (startDate == endDate) {
    		return ' takes place on ' + String.valueOf(DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('EEEEE')) + ' '+
    		startDate.day() + ' ' + String.valueOf(DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('MMMMM')) + 
    		' ' + startDate.year() + location;
    	} else {
    		return ' goes from ' + String.valueOf(DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('EEEEE')) + ' ' +
    		startDate.day() + ' ' + String.valueOf(DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('MMMMM')) + 
    		' to ' + String.valueOf(DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('EEEEE')) + ' ' + 
    		endDate.day() + ' ' + String.valueOf(DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('MMMMM')) + 
    		' ' + endDate.year() + location;
    	}
    } 
	
    public List<event> getDetails() {     
        
        return events;
        
    }

    Public Boolean gethasValues() {

		return (recordCount > 0) ? true : false;

    }

    public class event {

        public String name {get;set;}
        public String accountName {get;set;}
        public String jobNumber {get;set;}
        public String location {get;set;}
        public String venue {get;set;}
        public String pmName {get; set;}

        public event(string name, string accountName, 
                    string jobNumber, string location, 
                    string venue, string pmName) {
            this.name       = name;
            this.jobNumber  = jobNumber;
            this.accountName= accountName;
            this.location   = location;
            this.venue      = venue;
            this.pmName     = pmName;
        }
    }  
}