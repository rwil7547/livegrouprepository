({
	dragExpense : function(component, event, helper) {
        var dragEvent = $A.get("e.c:ExpenseDrag");
        dragEvent.setParams({ expenseId : component.get('v.expense.Id')});
        dragEvent.fire();

        var transferData = '{"type":"Expense"}';

        event.dataTransfer.setData("text/plain", transferData);
		//component.set('v.dragging',true);
	}
})