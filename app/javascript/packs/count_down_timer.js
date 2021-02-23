var Timer;
var TotalSeconds;


function CreateTimer(TimerID, Time) {
    Timer = document.getElementById(TimerID);
    TotalSeconds = Time;

    UpdateTimer();
    window.setTimeout("Tick()", 1000);
}

function Tick() {
    if (TotalSeconds <= 0) {
        alert("Your session has expired.  You will have to log back in!");
        window.location = "/login/logout";
        return;
    }

    TotalSeconds -= 1;
    UpdateTimer();
    window.setTimeout("Tick()", 1000);

}

function UpdateTimer() {
    var Seconds = TotalSeconds;

    var Days = Math.floor(Seconds / 86400);
    Seconds -= Days * 86400;

    var Hours = Math.floor(Seconds / 3600);
    Seconds -= Hours * (3600);

    var Minutes = Math.floor(Seconds / 60);
    Seconds -= Minutes * (60);


    //var TimeStr = ((Days > 0) ? Days + " days " : "") + LeadingZero(Hours) + ":" + LeadingZero(Minutes) + ":" + LeadingZero(Seconds)
	var TimeStr = ((Days > 0) ? Days + " days " : "") + ((Hours > 0) ? Hours + ((Hours == 1) ? " hour, " : " hours, ") : "") + ((Minutes > 0) ? Minutes + ((Minutes == 1) ? " minute, and " : " minutes, and ") : "") + Seconds + ((Seconds > 1) ? " seconds." : " second.")

    Timer.innerHTML = TimeStr;

    if(TotalSeconds == 120){
        alert("2 minute remain before your session expires!  Please save your work!");
    }

}


function LeadingZero(Time) {

    return (Time < 10) ? "0" + Time : + Time;

}