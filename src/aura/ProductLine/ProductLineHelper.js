({
	toggleSelect : function(component) {

        var productId = component.get('v.productId');
        if (document.getElementById(productId).checked === true){
            component.set('v.selected', false);
            var selectEvent = component.getEvent("productSelect");
        	selectEvent.setParams({
            	"productId" : component.get('v.productId'),
                "selected" : false});
        	selectEvent.fire();
        } else {
			component.set('v.selected', true);            
            var selectEvent = component.getEvent("productSelect");
        	selectEvent.setParams({
            	"productId" : component.get('v.productId'),
                "selected" : true});
        	selectEvent.fire();
        }
	}
})