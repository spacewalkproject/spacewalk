/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
 */
package com.redhat.rhn.taskomatic.task;


/**
 * Miscellaneous constants used by Taskomatic tasks
 *
 * @version $Rev $
 */

public class TaskConstants {

    public static final String TASK_QUERY_KSCLEANUP_FIND_CANDIDATES =
        "kickstartcleanup_find_candidates";

    public static final String TASK_QUERY_KSCLEANUP_FIND_PREREQ_ACTION =
        "kickstartcleanup_find_parent_action";

    public static final String TASK_QUERY_KSCLEANUP_REMOVE_ACTION =
        "kickstartcleanup_remove_action";

    public static final String TASK_QUERY_KSCLEANUP_FIND_FAILED_STATE_ID =
        "kickstartcleanup_find_failed_state_id";

    public static final String TASK_QUERY_KSCLEANUP_MARK_SESSION_FAILED =
        "kickstartcleanup_mark_session_failed";

    public static final String TASK_QUERY_SYNCHPROBESTATE_PROC =
        "synchprobestate_synch_proc";

    public static final String TASK_QUERY_PKGCLEANUP_FIND_CANDIDATES =
        "pkgcleanup_find_deleted_pkgs";

    public static final String TASK_QUERY_PKGCLEANUP_RESET_QUEUE =
        "pkgcleanup_reset_queue";

    public static final String TASK_QUERY_SESSION_CLEANUP =
        "taskomatic_session_cleanup";

    public static final String TASK_QUERY_TIME_SERIES_DATA_CLEANUP =
        "taskomatic_time_series_data_cleanup";

    public static final String TASK_QUERY_STATE_CHANGE_CLEANUP =
        "taskomatic_state_change_cleanup";

    public static final String TASK_QUERY_PROBE_STATE_CLEANUP =
        "taskomatic_probe_state_cleanup";

    public static final String TASK_QUERY_PACKAGE_CHANGELOG_CLEANUP =
        "taskomatic_package_changelog_cleanup";

    public static final String TASK_QUERY_ERRATA_QUEUE_FIND_CANDIDATES =
        "errataqueue_find_candidates";

    public static final String TASK_QUERY_ERRATA_QUEUE_ENQUEUE_SAT_ERRATA =
        "errataqueue_enqueue_sat_errata";

    public static final String TASK_QUERY_ERRATA_QUEUE_DEQUEUE_ERRATA_NOTIFICATION =
        "errataqueue_dequeue_errata_notification";

    public static final String TASK_QUERY_ERRATA_QUEUE_DEQUEUE_ERRATA =
        "errataqueue_dequeue_errata";

    public static final String TASK_QUERY_REPOMD_DRIVER_QUERY =
        "repomd_driver_query";

    public static final String TASK_QUERY_REPOMD_DEQUEUE =
        "repomd_dequeue";

    public static final String TASK_QUERY_REPOMD_DETAILS_QUERY =
        "repomd_details_query";

    public static final String TASK_QUERY_REPOMD_MARK_IN_PROGRESS =
        "repomd_mark_in_progress";

    public static final String TASK_QUERY_REPOMOD_CLEAR_IN_PROGRESS =
        "repomd_clear_in_progress";

    public static final String TASK_QUERY_ERRATA_QUEUE_FIND_AUTOUPDATE_SERVERS =
        "errataqueue_find_autoupdate_servers";

    public static final String TASK_QUERY_SUMMARYPOP_AWOL_SERVER_IN_ORGS =
        "summarypop_awol_server_in_orgs2";

    public static final String TASK_QUERY_SUMMARYPOP_ORGS_RECENT_ACTIONS =
        "summarypop_orgs_recent_actions";

    public static final String TASK_QUERY_INSERT_SUMMARY_QUEUE =
        "insert_summary_queue";

    public static final String TASK_QUERY_VERIFY_SUMMARY_QUEUE =
        "verify_summary_queue";

    public static final String TASK_QUERY_DAILY_SUMMARY_QUEUE =
        "daily_summary_queue_batch";

    public static final String TASK_QUERY_USERS_WANTING_REPORTS =
        "users_in_org_wanting_reports";

    public static final String TASK_QUERY_DEQUEUE_DAILY_SUMMARY =
        "dequeue_daily_summary";

    public static final String TASK_QUERY_USERS_AWOL_SERVERS =
        "users_awol_servers";

    public static final String TASK_QUERY_GET_ACTION_INFO = "get_action_info";

    public static final String TASK_QUERY_ERRATAMAILER_FIND_ERRATA =
        "erratamailer_find_errata";

    public static final String TASK_QUERY_ERRATAMAILER_GET_RELEVANT_SERVERS =
        "erratamailer_get_relevant_servers";

    public static final String TASK_QUERY_ERRATAMAILER_MARK_ERRATA_DONE =
        "erratamailer_mark_errata_done";

    public static final String TASK_QUERY_ERRATAMAILER_GET_USERINFO =
        "erratamailer_get_userinfo";

    public static final String TASK_QUERY_REPOMD_GENERATOR_CHANNEL_PACKAGES =
        "repomdgenerator_channel_packages";

    public static final String TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_FILES =
        "repomdgenerator_capability_files";

    public static final String TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_PROVIDES =
        "repomdgenerator_capability_provides";

    public static final String TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_REQUIRES =
        "repomdgenerator_capability_requires";

    public static final String TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_CONFLICTS =
        "repomdgenerator_capability_conflicts";

    public static final String TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_OBSOLETES =
        "repomdgenerator_capability_obsoletes";

    public static final String TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_RECOMMENDS =
        "repomdgenerator_capability_recommends";

    public static final String TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_SUGGESTS =
        "repomdgenerator_capability_suggests";

    public static final String TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_SUPPLEMENTS =
        "repomdgenerator_capability_supplements";

    public static final String TASK_QUERY_REPOMD_GENERATOR_CAPABILITY_ENHANCES =
        "repomdgenerator_capability_enhances";

    public static final String TASK_QUERY_REPOMD_GENERATOR_PACKAGE_CHANGELOG =
        "repomdgenerator_package_changelog";

    public static final String MODE_NAME = "Task_queries";

    public static final String TASK_QUERY_LOOKUP_REBOOT_ACTION_CLEANUP =
        "lookup_reboot_action_cleanup";

    public static final String TASK_QUERY_LOOKUP_CHILD_ACTION =
        "lookup_child_action";

    public static final String TASK_QUERY_LOOKUP_KICKSTART_SESSION_ID =
        "lookup_kickstart_session_id";

    private TaskConstants() { }
}
