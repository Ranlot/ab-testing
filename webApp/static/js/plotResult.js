$(document).ready(function() {

	$('#params_submit').click(function(event) {
		event.preventDefault();
		var pStar = $('input[name=pStar]').val();
		var pBaseLine = $('input[name=pBaseLine]').val();
		plotResult(pStar, pBaseLine);

	});

});

function addCommas(intNum) {
  return (intNum + '').replace(/(\d)(?=(\d{3})+$)/g, '$1,');
}

var convData = {
	element: 'plotConv',
	xkey: 'x',
	ykeys: ['y'],
	labels: ['y'],
	parseTime: false,
	lineColors: ['#F88040'],
	grid: true,
	gridTextColor: '#000000',
	verticalGrid: true,
	yLabelFormat: function (y) { return y.toFixed(1) + "%"; }
};


function plotResult(pStar, pBaseLine) {

	var guaranteedRateChange = 100. * (pStar - pBaseLine) / pBaseLine

	var queryResult = $.ajax({type:'POST', url:'/res', data:JSON.stringify({'pStar':pStar, 'pBaseLine':pBaseLine}), dataType:"json", contentType: "application/json"})

	queryResult.done(function(data) {

		//console.log(data);

		var maxSampleSize = 5000;  //this value should actually be inherited from the backend....

		var plotData = data['data']
		var sampleSizeCut = data['sampleSizeCut']

		//console.log(sampleSizeCut);

		if (pStar === pBaseLine) {
			var text2print = "probability of getting significant p-value even though there is absolutely no difference"
		} else if (pStar < pBaseLine)  {
			var text2print = sampleSizeCut <= maxSampleSize ? "chance of getting significant p-value decreased to about 1% after " + sampleSizeCut + " events; This is despite the fact that we have a guaranteed decrease of " + guaranteedRateChange.toFixed(1) + "%" : "did not converge even after " + maxSampleSize + " events";
		} else {
			var text2print = "Guaranteed increase of " + guaranteedRateChange.toFixed(1) + "%.  You would need about " + addCommas(sampleSizeCut) + " events"
		}

		$('#result').text(text2print);

		convData.data = plotData;

		$('#plotConv').empty();
		new Morris.Area(convData);

		});
}
