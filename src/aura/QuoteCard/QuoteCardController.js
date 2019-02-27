({
	doInit : function(component, event, helper) {
        if (component.get("v.quote.SBQQ__R00N70000001lX7YEAU__r")){
            component.set('v.editable',false);
            var quoteDocs = component.get("v.quote.SBQQ__R00N70000001lX7YEAU__r");
            for (var x = 0; x < quoteDocs.length; x++){
                if (quoteDocs[x].SBQQ__OutputFormat__c === 'PDF'){
                    component.set("v.pdf", quoteDocs[x].SBQQ__DocumentId__c);
                }
            }
        }
	},
    showDocument : function(component, event, helper) {
        event.stopPropagation();
        component.find('documentModal').getElement().classList.toggle('toggle');
        component.find('document').getElement().style.display = 'block';
    },
    handleShowDocument : function(component, event, helper){
	   if (event.getParam('quoteId') === component.get('v.quote.Id')){
           component.find('documentModal').getElement().classList.toggle('toggle');
           component.find('document').getElement().style.display = 'block';
       }
    },
    closeDocument : function(component, event, helper){
        component.find('documentModal').getElement().classList.toggle('toggle');
        component.find('document').getElement().style.display = 'none';
    },
    deleteDocument : function(component, event, helper){
        var deleteDocument = component.getEvent('deleteDocument');
        deleteDocument.setParams({docId : component.get('v.pdf')});
        deleteDocument.fire();
    },
    selectQuote : function(component, event, helper){
        var selectEvent = $A.get("e.c:SelectQuoteEvent");
        selectEvent.setParams({
            quoteId : component.get('v.quote.Id')
        });
        selectEvent.fire();
    },
    deselect : function(component, event, helper){
        var quote = component.get('v.quote');
        if (event.getParam('quoteId') !== quote.Id){
            quote.selected = false;
            component.set('v.quote',quote);
        } else {
            quote.selected = true;
            component.set('v.quote',quote);
        }
    }
})