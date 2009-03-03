ALTER TABLE rhnErrataNotificationQueue
    MODIFY
    next_action default(sysdate);
