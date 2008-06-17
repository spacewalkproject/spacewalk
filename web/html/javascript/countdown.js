
<!--  In order to use this script, you must define var secondsUntilRefresh in the head of your own document -->
function execute() {
        if(secondsUntilRefresh == 0)
                window.location= pageToRefreshTo;

        else
                secondsUntilRefresh -= 1;

        if(secondsUntilRefresh % 60 >= 10)
                document.getElementById("cntdwn").innerHTML = Math.floor(secondsUntilRefresh / 60) + ":" + (secondsUntilRefresh % 60);
        else
                document.getElementById("cntdwn").innerHTML = Math.floor(secondsUntilRefresh / 60) + ":0" + (secondsUntilRefresh % 60);
        window.setTimeout("execute()", 1000);
}

