({
	toggleSelect : function(component, event, helper) {
        helper.toggleSelect(component, false);
	},
    forceDeselect : function(component, event, helper){
        var productId = component.get('v.productId');
        if (document.getElementById(productId).checked === true){
            component.set('v.selected', false);
        }
    },
    stopPropagation : function(component, event, helper){
        event.stopPropagation();
        // event.preventDefault();
        helper.toggleSelect(component, true);
    }
})