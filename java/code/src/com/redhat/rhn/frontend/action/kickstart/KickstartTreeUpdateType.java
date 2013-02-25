package com.redhat.rhn.frontend.action.kickstart;

/**
 * types of kickstart tree update strategies
 * @author sherr
 */
public enum KickstartTreeUpdateType {
    ALL("all"), RED_HAT("red_hat"), NONE("none");
    private String type;

    /**
     * Create a new KickstartTreeUpdateType
     * @param updateType
     */
    KickstartTreeUpdateType(String updateType) {
        type = updateType;
    }

    /**
     * get the type
     * @return the registration type
     */
    public String getType() {
        return type;
    }

    /**
     * Set the type
     * @param updateType the update type to set
     */
    public void setType(String updateType) {
        type = updateType;
    }

    /**
     * Find the appropriate KTUT for a given string
     * @param typeIn the string to search for
     * @return the KTUT
     */
    public static KickstartTreeUpdateType find(String typeIn) {
        if (typeIn.equals(ALL.type)) {
            return ALL;
        }
        else if (typeIn.equals(RED_HAT.type)) {
            return RED_HAT;
        }
        else {
            return NONE;
        }
    }

    /**
     * Standard toString function
     * @return the String to return
     */
    public String toString() {
        return getType();
    }

}
