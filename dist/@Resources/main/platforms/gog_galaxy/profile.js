// Serialization of results to a file.
var productIDs = [];
var times = [];
var fs = require('fs');
function serialize() {
	console.log('Serializing...')
	var output = '';
	var i;
	for (i = 0; i < productIDs.length; i++) {
		output += productIDs[i] + '|' + times[i] + '\r\n'
	}
	console.log('\r\nProduct ID | Hours played');
	console.log(output);
	console.log(productIDs.length + ' games found');
	fs.write('cache\\gog_galaxy\\profile.txt', output, 'w');
}
// Get the name of the GOG profile so that the URL can be generated or exit early if the name is missing.
var system = require('system')
var args = system.args;
if (args.length < 2) {
	serialize();
	phantom.exit();
}
var url = 'https://www.gog.com/u/' + args[1] + '/games';
console.log('URL: ' + url);
// Parsing page contents.
var regexGame = /prof-game-statistics-game-id="(\d+)"><[\s\S]*?<span ng-bind="gameStatistics.playtime[\s\S]*?>([\s\S]*?)<\/span>/g;
var regexDays = /(\d+)d/g;
var regexHours = /(\d+)h/g;
var regexMinutes = /(\d+)m/g;
function parse(contents) {
	console.log('Parsing...');
	var foundNewIDs = false;
	var game;
	do {
		game = regexGame.exec(contents);
		if (game) {
			if (productIDs.indexOf(game[1]) < 0) {
				productIDs.push(game[1]);
				var hoursPlayed = 0;
				var value = regexDays.exec(game[2]); // Days of playtime
				if (value) hoursPlayed += Number(value[1]) * 24.0;
				value = regexHours.exec(game[2]); // Hours of playtime
				if (value) hoursPlayed += Number(value[1]);
				value = regexMinutes.exec(game[2]); // Minutes of playtime
				if (value) hoursPlayed += Number(value[1]) / 60.0;
				times.push(hoursPlayed);
				foundNewIDs = true;
			};
		}
	} while(game);
	return foundNewIDs;
}
// Downloading and navigating the page.
var page = require('webpage').create();
var processing = false;
var scrollPos = 0;
var interval = 500;
var attempts = 0;
var maxNumAttempts = 10;
function getScrollPos() {
	return page.evaluate(function() {return window.document.body.scrollTop;})
}
function scrollDown() {
	console.log('Scrolling down...')
	page.evaluate(function() {window.document.body.scrollTop = document.body.scrollHeight;});
}
page.onLoadFinished = function(status) {
	window.setInterval(function() {
		if (processing) return;
		var newScrollPos = getScrollPos();
		if (newScrollPos != scrollPos || attempts >= maxNumAttempts) {
			processing = true;
			scrollPos = newScrollPos;
			if (parse(page.content)) {
				scrollDown();
			} else {
				serialize()
				phantom.exit()
			}
			processing = false;
		} else {
			attempts += 1;
		}
	}, interval);
};
console.log('Downloading...');
page.open(url, function(status){
	scrollDown();
});
