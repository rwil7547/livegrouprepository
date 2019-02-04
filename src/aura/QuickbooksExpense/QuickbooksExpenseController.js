({
	dragExpense : function(component, event, helper) {
        var dragEvent = $A.get("e.c:ExpenseDrag");
        dragEvent.setParams({ expenseId : component.get('v.expense.Id')});
        dragEvent.fire();
		//component.set('v.dragging',true);
	}
})