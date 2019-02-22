({
	doInit : function(component, event, helper) {
        
        // Create the action
        var action = component.get("c.getQuotes"); 
        action.setParams({ 
            Id : component.get("v.recordId") 
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                var estimates = component.get('v.estimates');
                var contracts = component.get('v.contracts');
                var reconciliations = component.get('v.reconciliations');

                var quotes = response.getReturnValue();
                quotes.forEach(function(quote){
                   if (quote.Stage__c === 'Estimate'){
                       estimates.push(quote);
                   } else if (quote.Stage__c === 'Contract'){
                       contracts.push(quote);
                   } else if (quote.Stage__c === 'Reconciliation'){
                       reconciliations.push(quote);
                   }
                });
                component.set('v.estimates', estimates);
                component.set('v.contracts', contracts);
                component.set('v.reconciliations', reconciliations);
            }
        });
        $A.enqueueAction(action);   
	},
    refresh : function(component, event, helper) {

        // Create the action
        var action = component.get("c.getQuotes");
        action.setParams({
            Id : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                var estimates = [];
                var contracts = [];
                var reconciliations = [];

                var quotes = response.getReturnValue();
                quotes.forEach(function(quote){
                    if (quote.Id === event.getParam('id')){
                        quote.selected = true;
                    }

                    if (quote.Stage__c === 'Estimate'){
                        estimates.push(quote);
                    } else if (quote.Stage__c === 'Contract'){
                        contracts.push(quote);
                    } else if (quote.Stage__c === 'Reconciliation'){
                        reconciliations.push(quote);
                    }
                });
                component.set('v.estimates', estimates);
                component.set('v.contracts', contracts);
                component.set('v.reconciliations', reconciliations);
            }
        });
        $A.enqueueAction(action);
    }
})