({
	getTotals : function(component) {
        var lines = component.get('v.lines');
        var cosTotal = lines.reduce(function (total, line) {
            var amount = (line.SBQQ__Optional__c) ? 0 : line.Line_cost_total__c;             
            return total + amount;
        },0);
        var revTotal = lines.reduce(function (total, line) {
            var amount = (line.SBQQ__Optional__c) ? 0 : line.SBQQ__NetTotal__c;  
            return total + amount;
        },0);
        component.set('v.cosTotal', cosTotal);
        component.set('v.revTotal', revTotal);
    }
})