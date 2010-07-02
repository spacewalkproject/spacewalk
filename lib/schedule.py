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
# Copyright 2010 Aron Parsons <aron@redhat.com>
#

from spacecmd.utils import *

def help_schedule_cancel(self):
    print 'schedule_cancel: Cancel a scheduled action'
    print 'usage: schedule_cancel ID|* ...'

def complete_schedule_cancel(self, text, line, beg, end):
    return tab_completer(self.do_schedule_listpending('', True),
                              text)

def do_schedule_cancel(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_schedule_cancel()
        return

    # cancel all actions
    if '.*' in args:
        prompt = 'Do you really want to cancel all pending actions?'

        if self.user_confirm(prompt):
            strings = self.do_schedule_listpending('', True)
        else:
            return
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
        logging.info('Canceled action %s' % str(a))

    print 'Canceled %s actions' % str(len(actions))

####################

def help_schedule_details(self):
    print 'schedule_details: Show the details of a scheduled action'
    print 'usage: schedule_details ID'

def do_schedule_details(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_schedule_details()
        return

    try:
        id = int(args[0])
    except ValueError:
        logging.warning('%s is not a valid ID' % str(a))
        return

    completed = self.client.schedule.listCompletedSystems(self.session, id)
    failed = self.client.schedule.listFailedSystems(self.session, id)
    pending = self.client.schedule.listInProgressSystems(self.session, id)

    # put all the system arrays together for the summary
    all_systems = []
    all_systems.extend(completed)
    all_systems.extend(failed)
    all_systems.extend(pending)

    # schedule.getAction() API call would make this easier
    all_actions = self.client.schedule.listAllActions(self.session)
    action = 0
    for a in all_actions:
        if a.get('id') == id:
            action = a
            del all_actions
            break

    print_action_summary(action, systems = all_systems)
    
    print
    print 'Completed: %s' % str(len(completed))
    print 'Failed:    %s' % str(len(failed))
    print 'Pending:   %s' % str(len(pending))

    if len(completed):
        print
        print 'Completed Systems:'
        for s in completed:
            print '  %s' % s.get('server_name')

    if len(failed):
        print
        print 'Failed Systems:'
        for s in failed:
            print '  %s' % s.get('server_name')

    if len(pending):
        print
        print 'Pending Systems:'
        for s in pending:
            print '  %s' % s.get('server_name')

####################

def help_schedule_getoutput(self):
    print 'schedule_getoutput: Show the output from an action'
    print 'usage: schedule_getoutput ID'

def do_schedule_getoutput(self, args):
    args = parse_arguments(args)

    if not len(args):
        self.help_schedule_getoutput()
        return
    elif len(args) > 1:
        systems = args[1:]
    else:
        systems = []

    try:
        action_id = int(args[0])
    except ValueError:
        logging.error('%s is not a valid action ID' % str(a))
        return

    script_results = None
    try:
        #XXX: Bugzilla 584869
        script_results = \
            self.client.system.getScriptResults(self.session, action_id)
    except:
        pass

    # scripts have a different data structure than other actions
    if script_results:
        add_separator = False
        for r in script_results:
            if add_separator: print self.SEPARATOR
            add_separator = True

            print 'System:      %s' % 'UNKNOWN'
            print 'Start Time:  %s' % format_time(r.get('startDate').value)
            print 'Stop Time:   %s' % format_time(r.get('stopDate').value)
            print 'Return Code: %s' % str(r.get('returnCode'))
            print 'Output:'
            print r.get('output')
    else:
        add_separator = False

        completed = self.client.schedule.listCompletedSystems(self.session,
                                                              action_id)

        failed = self.client.schedule.listFailedSystems(self.session,
                                                        action_id)

        #XXX: Bugzilla 608868
        for action in completed + failed:
            if add_separator: print self.SEPARATOR
            add_separator = True

            print_action_output(action)

#        completed = self.client.schedule.listCompletedSystems(self.session, id)
#
#        if len(completed):
#            print
#            print 'Completed Systems:'
#
#            add_separator = False
#            for r in completed:
#                if add_separator:
#                    print self.SEPARATOR
#
#                add_separator = True
#
#                print 'System:      %s' % r.get('server_name')
#                print 'Completed:   %s' % re.sub('T', ' ',
#                                                 r.get('timestamp').value)
#
#                print
#                print r.get('message')
#
#        failed = self.client.schedule.listFailedSystems(self.session, id)
#
#        if len(failed):
#            print
#            print 'Failed Systems:'
#
#            add_separator = False
#            for r in failed:
#                if add_separator:
#                    print self.SEPARATOR
#
#                add_separator = True
#
#                print 'System:      %s' % r.get('server_name')
#                print 'Completed:   %s' % re.sub('T', ' ',
#                                                 r.get('timestamp').value)
#
#                print
#                print r.get('message')

####################

def help_schedule_listpending(self):
    print 'schedule_listpending: List pending actions'
    print 'usage: schedule_listpending [LIMIT]'

def do_schedule_listpending(self, args, doreturn=False):
    actions = self.client.schedule.listInProgressActions(self.session)

    if not len(actions): return

    if doreturn:
        return [str(a.get('id')) for a in actions]
    else:
        try:
            limit = int(args[0])
        except ValueError:
            limit = len(actions)

        add_separator = False

        for i in range(0, limit):
            if add_separator: print self.SEPARATOR
            add_separator = True

            systems = self.client.schedule.listInProgressSystems(\
                          self.session, actions[i].get('id'))

            print_action_summary(actions[i], systems)

####################

def help_schedule_listcompleted(self):
    print 'schedule_listcompleted: List completed actions'
    print 'usage: schedule_listcompleted [LIMIT]'

def do_schedule_listcompleted(self, args, doreturn=False):
    actions = self.client.schedule.listCompletedActions(self.session)

    if not len(actions): return

    if doreturn:
        return [str(a.get('id')) for a in actions]
    else:
        try:
            limit = int(args[0])
        except:
            limit = len(actions)

        add_separator = False

        for i in range(0, limit):
            if add_separator: print self.SEPARATOR
            add_separator = True

            systems = self.client.schedule.listCompletedSystems(\
                          self.session, actions[i].get('id'))

            print_action_summary(actions[i], systems)

####################

def help_schedule_listfailed(self):
    print 'schedule_listfailed: List failed actions'
    print 'usage: schedule_listfailed [LIMIT]'

def do_schedule_listfailed(self, args, doreturn=False):
    actions = self.client.schedule.listFailedActions(self.session)

    if not len(actions): return

    if doreturn:
        return [str(a.get('id')) for a in actions]
    else:
        try:
            limit = int(args[0])
        except:
            limit = len(actions)

        add_separator = False

        for i in range(0, limit):
            if add_separator: print self.SEPARATOR
            add_separator = True

            systems = self.client.schedule.listFailedSystems(\
                          self.session, actions[i].get('id'))

            print_action_summary(actions[i], systems)

####################

def help_schedule_listarchived(self):
    print 'schedule_listarchived: List archived actions'
    print 'usage: schedule_listarchived [LIMIT]'

def do_schedule_listarchived(self, args, doreturn=False):
    actions = self.client.schedule.listArchivedActions(self.session)

    if not len(actions): return

    if doreturn:
        return [str(a.get('id')) for a in actions]
    else:
        try:
            limit = int(args[0])
        except:
            limit = len(actions)

        add_separator = False

        for i in range(0, limit):
            if add_separator: print self.SEPARATOR
            add_separator = True

            completed = \
                self.client.schedule.listCompletedSystems(self.session,
                                                   actions[i].get('id'))
            failed = \
                self.client.schedule.listFailedSystems(self.session,
                                                       actions[i].get('id'))
            pending = \
                self.client.schedule.listInProgressSystems(self.session,
                                                   actions[i].get('id'))

            all_systems = completed + failed + pending

            print_action_summary(actions[i], all_systems)

# vim:ts=4:expandtab:
