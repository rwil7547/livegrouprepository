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
                       quote.position = estimates.length;
                       estimates.push(quote);
                   } else if (quote.Stage__c === 'Contract'){
                       quote.position = contracts.length;
                       contracts.push(quote);
                   } else if (quote.Stage__c === 'Reconciliation'){
                       quote.position = reconciliations.length;
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
                        quote.position = estimates.length;
                        estimates.push(quote);
                    } else if (quote.Stage__c === 'Contract'){
                        quote.position = contracts.length;
                        contracts.push(quote);
                    } else if (quote.Stage__c === 'Reconciliation'){
                        quote.position = reconciliations.length;
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
    deleteDocument : function(component, event, helper){

	    var deleteDoc = component.get('c.deleteDocumentApex');
	    deleteDoc.setParams({docId : event.getParam('docId')});

	    deleteDoc.setCallback(this, function(response){
	        if (response.getState() === 'SUCCESS' && response.getReturnValue()){
                var refresh = $A.get("e.c:Refresh");
                refresh.setParams({
                    id : component.get('v.quote.Id')
                });
                refresh.fire();
            }
        });
	    $A.enqueueAction(deleteDoc);
    },
    toggleEstimates : function(component, event, helper){
	    component.set('v.estimatesOpen',!component.get('v.estimatesOpen'));
    },
    toggleContracts : function(component, event, helper){
        component.set('v.contractsOpen',!component.get('v.contractsOpen'));
    },
    toggleReconciliations : function(component, event, helper){
        component.set('v.reconciliationsOpen',!component.get('v.reconciliationsOpen'));
    },
    assessChange : function(component, event, helper){
	    if (event.getParam("oldValue")){
            var refresh = $A.get("e.c:Refresh");
            refresh.setParams({
                id : component.get('v.quote.Id')
            });
            refresh.fire();
        }
    }

})