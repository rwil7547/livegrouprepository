({
    clone : function(component) {
        var clone = JSON.parse(JSON.stringify(component.get('v.original')));
        component.set('v.line',clone);
        component.set('v.optional',clone.SBQQ__Optional__c);
    },
    fireOpenEdit : function(Id) {
        var selectEvt = $A.get("e.c:LineSelected");
        selectEvt.setParams({ "Id" : Id });
        selectEvt.fire();  
    }, 
	fireLineChange : function(component, line, operation) {
		var lineEvent = component.getEvent('lineEdit');
        lineEvent.setParams({
            'line' : line,
            'id' : line.Id,
            'operation' : operation
        });
        lineEvent.fire();
	},
    closeEdit : function(component){

        console.log(component.get('v.line.SBQQ__Description__c') + ' : close called');

        document.getElementById(component.get('v.line.Id')).classList.remove('selected');
        component.set('v.editmode', false);
    },
    calculateTotal : function(component, event){        
        var id = component.get('v.line.Id');
        var expenses = component.get('v.expenses');
        
        var total = 0;
        for (var x = 0; x < expenses.length; x++){
            if (expenses[x].QuoteLine__c === id){
            	total += expenses[x].Amount__c;                
            }
        }       
        component.set('v.expensesTotal',total);
    },
    formatDescription : function(description){
        // console.log('substr is ' + description.substring(0, 3));
        // console.log('endstr is ' + description.substring(description.length - 4, description.length));
        // console.log('long endstr is ' + description.substring(description.length - 11, description.length));
        //
        if (description.substring(0, 3) === '<p>'){
            description = description.substring(3);
        }
        if (description.substring(description.length - 11, description.length) === '<p><br></p>'){
            description = description.substring(0, description.length - 11);            
        } else if (description.substring(description.length - 4, description.length) === '</p>'){
            description = description.substring(0, description.length - 4);
        }
       
        return description;
    },
    inputValid : function(component){

        var valid = (!isNaN(component.get('v.line.SBQQ__Quantity__c')) &&
                     !isNaN(component.get('v.line.SBQQ__UnitCost__c')) &&
                     !isNaN(component.get('v.line.SBQQ__UnitCost__c')));

        return valid;
    }
})