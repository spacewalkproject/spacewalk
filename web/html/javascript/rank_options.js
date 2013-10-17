/**
 * Copyright (c) 2008--2013 Red Hat, Inc.
 * All Rights Reserved.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 *
 */

/**
This file contains java script code related to ConfigChannel Rankings and Kickstart Scripts Ordering pages.
Basically functions to handle things like the up and down buttons. 
Note this file uses a couple of functions from 'Prototype' library 
to asynchronously post to the channel rankings update page.
*/

function move_selected_up(rankingWidgetName) {
   return move_selected(rankingWidgetName, true);
}
function move_selected_down(rankingWidgetName) {
   return move_selected(rankingWidgetName, false);
}


/**
This function gets called when the 'up'/'down' button/arrow/image is pressed.
Behaviour, moves the selected Item in the rankingWidget up/down by one step 
depending on the boolean value moveUp. 
Also calls the update Url action asynchronously if provided(who does things like 
saving to a set etc..).. 
@param rankingWidgetName the name of the ranking widget list box.
@param updateUrl the url that will be called asynchronously, if some set
                  has to be updated as a result of this action. Pass 
                  null if no such actions are required...
@param moveUp the direction in which the selected item must be moved 
                (up if true, down if false).
*/
function move_selected(rankingWidgetName, moveUp) {

    var element = document.getElementById(rankingWidgetName);    
    var index = element.selectedIndex;
    if (index > -1) {
         var selected = element.options[index];
        if ((moveUp && index > 0) || 
                    (!moveUp && index < element.options.length - 1)) {
            moveToIndex = index - 1;
            if (!moveUp) {
                moveToIndex = index + 1;
            }

            element.options[index] = new Option(element.options[moveToIndex].text,
                                     element.options[moveToIndex].value, false, false);
            element.options[moveToIndex] = selected;
        }
   }
   // return false so that a form submit doesnot happen
   return false;
}

/**
This function should get called when a form submit action is clicked.
Behaviour:
1) Basically joins the values of the rankingWidgetElements into a comma separated string,
2) Stores the value in the element provided by 'storerName'
3) Does a form submit..
This comma separated magic is required for handling cases where the browser
supports javascript but does not support ajax..
@param rankingWidgetName the name of the ranking widget list box.
@param storerName name of the element in whom the CS string will be stored
       ('rankedValues' in the case of SDC channel rankings)
@param formName name of the form who has to be submitted.
*/
function handle_ranking_dispatch (rankingWidgetName, storerName, formName) {
    element = document.getElementById(rankingWidgetName);
    storer = document.getElementById(storerName);
    form = document.getElementById(formName);
    storer.value = make_ranking_csv(rankingWidgetName);
    form.submit();
    return true;
}

/**
 * This function does the same thing that handle_ranking_dispatch does,
 * but without submitting the form. This is necessary so that you can submit
 * a form with more than one rankingWidget in it. The last rakingWidget should
 * call handle_config_channels_dispatch to submit the form.
 * @param rankingWidgetName the name of the ranking widget list box.
 * @param storerName name of the element in whom the CS string will be stored
 *        ('rankedValues' in the case of SDC channel rankings)
 * @param formName name of the form who has to be submitted.
 */
function handle_ranking (rankingWidgetName, storerName, formName) {
    element = document.getElementById(rankingWidgetName);
    storer = document.getElementById(storerName);
    form = document.getElementById(formName);
    storer.value = make_ranking_csv(rankingWidgetName);
    return false;
}

/**
This function binds the values of each element of a list box  ('listBox') in a comma separated string.
@param listBoxName  the name of the list box element who's transform is desired
@return a comma separated list of list elements...
*/
function make_ranking_csv(listBoxName) {
    var values =  new Array();
    var listBox  = document.getElementById(listBoxName);
    for (var i = 0; i < listBox.options.length; i++) {
        values.push(listBox.options[i].value);
    }
    return values.join(',');
}
