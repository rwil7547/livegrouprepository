({
	doInit : function(component, event, helper) {
        
        // Create the action
        var action = component.get("c.getQuotes"); 
        action.setParams({ 
            Id : component.get("v.recordId") 
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                component.set("v.quotes", response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);   
	},
    refresh : function(component, event, helper) {

	    console.log('should be refreshing');


        // Create the action
        var action = component.get("c.getQuotes");
        action.setParams({
            Id : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){

                var quotes = response.getReturnValue();
                quotes.forEach(function(element){
                    if (element.Id === event.getParam('id')){
                        element.selected = true;
                    }
                });

                component.set("v.quotes", quotes);
            }
        });
        $A.enqueueAction(action);
    }
})