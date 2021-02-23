/* 	Realtime Countdown v1.1
 *	(C) 2006 Nathan Bolender
 *	www.nathanbolender.com
*/

/*	**********************************************************	*/
/*	**********************************************************	*/
/*	**************** DO NOT EDIT BELOW THIS LINE**************	*/
/*	**********************************************************	*/
/*	**********************************************************	*/

var version = '1.1';

function countdown(elementString, dateString, mode, name) { // date in format "December 25, 2005 00:00:00 GMT-500"
/////////////////////////////////////////
//	usage:
//	countdown(str element, str date [, int mode [, str name]])
//	element is the element that will contain the countdown
//	date is the countdown (or countup) date in this standard form:
//		December 25, 2005 00:00:00 GMT-500
/////
//	Modes:
//	0 (default): Time until My Birthday - 06:33:00 11/25/05: 6 hours, 28 minutes, and 36 seconds.
//	1: My Birthday - 06:33:00 11/25/05: 6 hours, 28 minutes, and 36 seconds.
//	2: 6 hours, 28 minutes, and 36 seconds.
//	3: 6 hours, 28 minutes, and 36 seconds
if (mode == null) mode = 0;
if (name == null) name = '0';
	var clock = document.getElementById(elementString);
	var eventdate = new Date(dateString); // in format "January 1, 2005 00:00:00 GMT"
	now = new Date();
	nowtime = now.getTime(); // now in milliseconds
	// obtain local UTC offset and convert to msec
	//localOffset = d.getTimezoneOffset() * 60000;
	// obtain UTC time in msec
	//utc = nowtime + localOffset;
	//nowtime = eventdate.getTime(); // now in milliseconds
	eventtime = eventdate.getTime(); // event in milliseconds

		var eventhour = eventdate.getHours();
		var eventminute = eventdate.getMinutes();
		var eventsecond = eventdate.getSeconds();
		var eventmonth = eventdate.getMonth()+1;
		var eventday = eventdate.getDate();
		var eventyear = eventdate.getFullYear();

	timeleft = Math.round((eventtime-nowtime) / 1000); // timeleft in seconds

	var passed = 0;
	if (timeleft < 0) { // if event has passed
		timeleft = Math.abs(timeleft);
		passed = 1;
	}

	if (timeleft != 0) {
		// Let's get a whole bunch of values
		years = Math.floor(timeleft/31556926);
		months = Math.floor((timeleft%31556926)/2629744);
		days = Math.floor(((timeleft%31556926)%2629744)/86400);
		hours = Math.floor((((timeleft%31556926)%2629744)%86400)/3600);
		minutes = Math.floor(((((timeleft%31556926)%2629744)%86400)%3600)/60);
		seconds = Math.floor(((((timeleft%31556926)%2629744)%86400)%3600)%60);
	}

	// Now lets build a response to print
	var togo = ''; // set up our variable

	if (mode == 0) {
		togo += 'Time ';
		if (passed != 1) {
			togo += 'until ';
		} else {
			togo += 'since ';
		}
	}

	if ((mode != 2) && (mode != 3)) {
		togo += '<strong>';
		if (name != '0') togo += name + ' - ';
		if ((eventhour + eventminute + eventsecond) != 0) {
			togo += eventhour + ':' + eventminute;
			if (eventsecond != 0) togo += ':' + eventsecond;
			togo += ' on ';
		}
		togo += eventmonth + '/' + eventday;
		if (eventyear != now.getFullYear()) togo += '/' + eventyear;
		togo += '</strong>: ';
	}

	if (timeleft != 0) {
		if (years > 0) {
			togo += years + ' year';
			if (years > 1) togo += 's';
			if (months > 0) togo += ',';
			if ((minutes!=0)||(seconds!=0)||(hours!=0)||(days!=0)||(months!=0)) togo += ' ';
		}

		if (months > 0) {
			togo += months + ' month';
			if (months > 1) togo += 's';
			if (days > 0) togo += ',';
			if ((minutes!=0)||(seconds!=0)||(hours!=0)||(days!=0)) togo += ' ';
		}

		if (days > 0) {
			togo += days + ' day';
			if (days > 1) togo += 's';
			if (hours > 0) togo += ',';
			if ((minutes!=0)||(seconds!=0)||(hours!=0)) togo += ' ';
		}

		if (hours > 0) {
			togo += hours + ' hour';
			if (hours > 1) togo += 's';
			if (minutes > 0) togo += ',';
			if ((minutes!=0)||(seconds!=0)) togo += ' ';
		}

		if (minutes > 0) {
			togo += minutes + ' minute';
			if (minutes > 1) togo += 's';
			if (seconds > 0) togo += ',';
			if (seconds != 0) togo += ' ';
		}

		if (seconds > 0) {
			togo += seconds + ' second';
			if (seconds > 1) togo += 's';
		}

		var expld = togo.split(', ');
		// EXAMPLE:
		// 0 => 5 years
		// 1 => 5 months
		// 2 => 5 days
		// 3 => 5 hours
		// 4 => 5 minutes
		// 5 => 5 seconds

		var exlast = expld.length-1;
		var todo = '';
		var i;

		for (i=0 ; i<expld.length ; i++) {
			value = expld[i];
			todo += value;
			if ((i != exlast) && (expld.length!=2)) todo += ', ';
			if ((expld.length == 2) && (i != exlast)) todo += ' ';
			if (i == (exlast-1)) todo += 'and ';
			if ((i == exlast) && (passed == 1)) todo += ' ago';
			if ((i == exlast) && (mode != 3)) todo += '.';
		}
	} else {
		var todo = togo + ' Now!';
	}

	// Now lets print it
	clock.innerHTML = todo;

	setTimeout('countdown(\'' + elementString + '\', \'' + dateString + '\', ' + mode + ', "' + name + '");', 1000); // re-execute the function in 1 second
}