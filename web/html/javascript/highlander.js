/*
 * highlander - there can be only one.
 * Function used by package search page to ensure only relevant or channel
 * arches are selected but not both.
*/
function highlander(field) {

    if (field.name == 'relevant') {

        /*
         * turning off the checkbox should select all of the arches
         * and vice versa.
         */
        var options = document.forms[1].channel_arch.options;
        for (i = 0; i < options.length; i++) {
            if (options[i].text[0] != '*') {
                options[i].selected = !field.checked;
            }
            else {
                options[i].selected = false;
            }
        }
    } else if (field.name == 'channel_arch') {
        /*
         * turning off the checkbox should select all of the arches
         * and vice versa.
         */
        var options = document.forms[1].channel_arch.options;
        var anyselected = false;

        for (i = 0; i < options.length; i++) {
            if (options[i].selected) {
                anyselected = true;
                break;
            }
        }

        document.forms[1].relevant.checked = !anyselected;
    }
};
