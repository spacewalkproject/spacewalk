--
-- Copyright (c) 2008--2013 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--
--data for rhnKickstartSessionState

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Created', 'created',
        'Kickstart session created, but has not yet been used.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Deployed', 'deployed',
        'Files required for kickstart action have been installed.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Injected', 'injected',
        'The system configuration has been modified to begin kickstart upon next boot.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Restarted', 'restarted',
        'The system has been restarted in order to begin the kickstart process.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Configuration accessed', 'configuration_accessed',
        'The system has downloaded the kickstart configuraton file from Spacewalk.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Started', 'started',
        'The initial files required for anaconda have been downloaded.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'In Progress', 'in_progress',
        'The system is downloading the RPMs required to install.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Registration Complete', 'registered',
        'The system has successfully registered with Spacewalk after kickstarting.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Package Synch', 'package_synch',
        'Package synchronization in progress.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Package Synch Scheduled',
        'package_synch_scheduled', 'Package synchronization scheduled.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Configuration Deployment',
        'configuration_deploy', 'Configuration files are being deployed.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Complete', 'complete',
        'Kickstart complete.'
       );

insert
  into rhnKickstartSessionState
       (id, name, label, description)
values (sequence_nextval('rhn_ks_session_state_id_seq'), 'Failed', 'failed',
        'Kickstart failed.'
       );

commit;

