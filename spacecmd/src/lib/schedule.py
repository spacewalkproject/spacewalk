#
# Licensed under the GNU General Public License Version 3
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Copyright 2013 Aron Parsons <aronparsons@gmail.com>
#

# NOTE: the 'self' variable is an instance of SpacewalkShell

# wildcard import
# pylint: disable=W0401,W0614

# unused argument
# pylint: disable=W0613

# invalid function name
# pylint: disable=C0103

import base64
from operator import itemgetter
try:
    from xmlrpc import client as xmlrpclib
except ImportError:
    import xmlrpclib
from spacecmd.utils import *


def print_schedule_summary(self, action_type, args):
    args = args.split() or []

    if args:
        begin_date = parse_time_input(args[0])
        logging.debug('Begin Date: %s' % begin_date)
    else:
        begin_date = None

    if len(args) > 1:
        end_date = parse_time_input(args[1])
        logging.debug('End Date:   %s' % end_date)
    else:
        end_date = None

    if action_type == 'pending':
        actions = self.client.schedule.listInProgressActions(self.session)
    elif action_type == 'completed':
        actions = self.client.schedule.listCompletedActions(self.session)
    elif action_type == 'failed':
        actions = self.client.schedule.listFailedActions(self.session)
    elif action_type == 'archived':
        actions = self.client.schedule.listArchivedActions(self.session)
    elif action_type == 'all':
        # get actions in all states except archived
        in_progress = self.client.schedule.listInProgressActions(self.session)
        completed = self.client.schedule.listCompletedActions(self.session)
        failed = self.client.schedule.listFailedActions(self.session)

        actions = []
        added = []
        for action in in_progress + completed + failed:
            if action.get('id') not in added:
                actions.append(action)
                added.append(action.get('id'))
    else:
        return

    if not actions:
        return

    print('ID      Date                 C    F    P     Action')
    print('--      ----                ---  ---  ---    ------')

    for action in sorted(actions, key=itemgetter('id'), reverse=True):
        if begin_date:
            if action.get('earliest') < begin_date:
                continue

        if end_date:
            if action.get('earliest') > end_date:
                continue

        if self.check_api_version('10.11'):
            print('%s  %s   %s  %s  %s    %s' %
                  (str(action.get('id')).ljust(6),
                   action.get('earliest'),
                   str(action.get('completedSystems')).rjust(3),
                   str(action.get('failedSystems')).rjust(3),
                   str(action.get('inProgressSystems')).rjust(3),
                   action.get('name')))
        else:
            # Satellite 5.3 compatibility
            in_progress = \
                self.client.schedule.listInProgressSystems(self.session,
                                                           action.get('id'))

            completed = \
                self.client.schedule.listCompletedSystems(self.session,
                                                          action.get('id'))

            failed = \
                self.client.schedule.listFailedSystems(self.session,
                                                       action.get('id'))

            print('%s  %s   %s  %s  %s    %s' %
                  (str(action.get('id')).ljust(6),
                   action.get('earliest'),
                   str(len(completed)).rjust(3),
                   str(len(failed)).rjust(3),
                   str(len(in_progress)).rjust(3),
                   action.get('name')))

####################


def help_schedule_cancel(self):
    print('schedule_cancel: Cancel scheduled actions')
    print('usage: schedule_cancel ID|* ...')


def complete_schedule_cancel(self, text, line, beg, end):
    try:
        actions = self.client.schedule.listInProgressActions(self.session)
        return tab_completer([str(a.get('id')) for a in actions], text)
    except xmlrpclib.Fault:
        return []


def do_schedule_cancel(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_schedule_cancel()
        return

    # cancel all actions
    if '.*' in args:
        if not self.user_confirm('Cancel all pending actions [y/N]:'):
            return

        actions = self.client.schedule.listInProgressActions(self.session)
        strings = [a.get('id') for a in actions]
    else:
        strings = args

    # convert strings to integers
    actions = []
    for a in strings:
        try:
            actions.append(int(a))
        except ValueError:
            logging.warning('%s is not a valid ID' % str(a))
            continue

    self.client.schedule.cancelActions(self.session, actions)

    for a in actions:
        logging.info('Canceled action %i' % a)

    print('Canceled %i action(s)' % len(actions))

####################


def help_schedule_reschedule(self):
    print('schedule_reschedule: Reschedule failed actions')
    print('usage: schedule_reschedule ID|* ...')


def complete_schedule_reschedule(self, text, line, beg, end):
    try:
        actions = self.client.schedule.listFailedActions(self.session)
        return tab_completer([str(a.get('id')) for a in actions], text)
    except xmlrpclib.Fault:
        return []


def do_schedule_reschedule(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_schedule_reschedule()
        return

    failed_actions = self.client.schedule.listFailedActions(self.session)
    failed_actions = [a.get('id') for a in failed_actions]

    to_reschedule = []

    # reschedule all failed actions
    if '.*' in args:
        if not self.user_confirm('Reschedule all failed actions [y/N]:'):
            return
        to_reschedule = failed_actions
    else:
        # use the list of action IDs passed in
        for a in args:
            try:
                action_id = int(a)

                if action_id in failed_actions:
                    to_reschedule.append(action_id)
                else:
                    logging.warning('%i is not a failed action' % action_id)
            except ValueError:
                logging.warning('%s is not a valid ID' % str(a))
                continue

    if not to_reschedule:
        logging.warning('No failed actions to reschedule')
        return

    self.client.schedule.rescheduleActions(self.session, to_reschedule, True)

    print('Rescheduled %i action(s)' % len(to_reschedule))

####################


def help_schedule_details(self):
    print('schedule_details: Show the details of a scheduled action')
    print('usage: schedule_details ID')


def do_schedule_details(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_schedule_details()
        return

    try:
        action_id = int(args[0])
    except ValueError:
        logging.warning('%s is not a valid ID' % str(action_id))
        return

    completed = self.client.schedule.listCompletedSystems(self.session,
                                                          action_id)

    failed = self.client.schedule.listFailedSystems(self.session, action_id)

    pending = self.client.schedule.listInProgressSystems(self.session,
                                                         action_id)

    # put all the system arrays together for the summary
    all_systems = []
    all_systems.extend(completed)
    all_systems.extend(failed)
    all_systems.extend(pending)

    # schedule.getAction() API call would make this easier
    all_actions = self.client.schedule.listAllActions(self.session)
    action = None
    for a in all_actions:
        if a.get('id') == action_id:
            action = a
            del all_actions
            break

    print('ID:        %i' % action.get('id'))
    print('Action:    %s' % action.get('name'))
    print('User:      %s' % action.get('scheduler'))
    print('Date:      %s' % action.get('earliest'))
    print('')
    print('Completed: %s' % str(len(completed)).rjust(3))
    print('Failed:    %s' % str(len(failed)).rjust(3))
    print('Pending:   %s' % str(len(pending)).rjust(3))

    if completed:
        print('')
        print('Completed Systems')
        print('-----------------')
        for s in completed:
            print(s.get('server_name'))

    if failed:
        print('')
        print('Failed Systems')
        print('--------------')
        for s in failed:
            print(s.get('server_name'))

    if pending:
        print('')
        print('Pending Systems')
        print('---------------')
        for s in pending:
            print(s.get('server_name'))

####################


def help_schedule_getoutput(self):
    print('schedule_getoutput: Show the output from an action')
    print('usage: schedule_getoutput ID')


def do_schedule_getoutput(self, args):
    arg_parser = get_argument_parser()

    (args, _options) = parse_command_arguments(args, arg_parser)

    if not args:
        self.help_schedule_getoutput()
        return

    try:
        action_id = int(args[0])
    except ValueError:
        logging.error('%s is not a valid action ID' % str(args[0]))
        return

    script_results = None
    try:
        script_results = \
            self.client.system.getScriptResults(self.session, action_id)
    except xmlrpclib.Fault:
        pass

    # scripts have a different data structure than other actions
    if script_results:
        add_separator = False
        for r in script_results:
            if add_separator:
                print(self.SEPARATOR)
            add_separator = True

            if r.get('serverId'):
                system = self.get_system_name(r.get('serverId'))
            else:
                system = 'UNKNOWN'

            print('System:      %s' % system)
            print('Start Time:  %s' % r.get('startDate'))
            print('Stop Time:   %s' % r.get('stopDate'))
            print('Return Code: %i' % r.get('returnCode'))
            print('')
            print('Output')
            print('------')
            if r.get('output_enc64'):
                print(base64.b64decode(r.get('output')))
            else:
                print(r.get('output').encode('UTF8'))

    else:
        completed = self.client.schedule.listCompletedSystems(self.session,
                                                              action_id)

        failed = self.client.schedule.listFailedSystems(self.session,
                                                        action_id)

        add_separator = False

        for action in completed + failed:
            if add_separator:
                print(self.SEPARATOR)
            add_separator = True

            print('System:    %s' % action.get('server_name'))
            print('Completed: %s' % action.get('timestamp'))
            print('')
            print('Output')
            print('------')
            print(action.get('message'))

####################


def help_schedule_listpending(self):
    print('schedule_listpending: List pending actions')
    print('usage: schedule_listpending [BEGINDATE] [ENDDATE]')
    print('')
    print(self.HELP_TIME_OPTS)


def do_schedule_listpending(self, args):
    return self.print_schedule_summary('pending', args)

####################


def help_schedule_listcompleted(self):
    print('schedule_listcompleted: List completed actions')
    print('usage: schedule_listcompleted [BEGINDATE] [ENDDATE]')
    print('')
    print(self.HELP_TIME_OPTS)


def do_schedule_listcompleted(self, args):
    return self.print_schedule_summary('completed', args)

####################


def help_schedule_listfailed(self):
    print('schedule_listfailed: List failed actions')
    print('usage: schedule_listfailed [BEGINDATE] [ENDDATE]')
    print('')
    print(self.HELP_TIME_OPTS)


def do_schedule_listfailed(self, args):
    return self.print_schedule_summary('failed', args)

####################


def help_schedule_listarchived(self):
    print('schedule_listarchived: List archived actions')
    print('usage: schedule_listarchived [BEGINDATE] [ENDDATE]')
    print('')
    print(self.HELP_TIME_OPTS)


def do_schedule_listarchived(self, args):
    return self.print_schedule_summary('archived', args)

####################


def help_schedule_list(self):
    print('schedule_list: List all actions')
    print('usage: schedule_list [BEGINDATE] [ENDDATE]')
    print('')
    print(self.HELP_TIME_OPTS)


def do_schedule_list(self, args):
    return self.print_schedule_summary('all', args)
