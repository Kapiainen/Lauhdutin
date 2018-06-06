var system = require('system')
var args = system.args;
if (args.length < 2) {
	phantom.exit();
}
url = 'https://www.gog.com/u/' + args[1] + '/games'
console.log(url);
var fs = require('fs');
var page = require('webpage').create();
var productIDs = [];
page.onLoadFinished = function() {
	console.log('onLoadFinished');
	window.setInterval(function() {
		var lines = page.content.split(/\r?\n/);
		var i;
		var foundNewIDs = false;
		for (i = 0; i < lines.length; i++) {
			id = lines[i].match(/prof-game-statistics-game-id="(\d+)"/);
			if (id != null && (productIDs.indexOf(id[1]) < 0)) {
				productIDs.push(id[1]);
				foundNewIDs = true;
			}
		}
		if (foundNewIDs == true) {
			page.evaluate(function() {window.document.body.scrollTop = document.body.scrollHeight;});
		} else {
			output = productIDs.join('\r\n');
			console.log(output);
			fs.write('cache\\gog_galaxy\\profile.txt', output, 'w');
			phantom.exit();
		}
	}, 500);
};
page.open(url,function(status){page.evaluate(function(){});});
