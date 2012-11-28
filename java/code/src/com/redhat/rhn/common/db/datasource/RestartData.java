package com.redhat.rhn.common.db.datasource;

import java.util.List;
import java.util.Map;

/**
 * An object that stores data needed for a sql query so that it can be
 * restarted if necessary.
 * @author sherr
 */
public class RestartData {
    private String sql;
    private Map<String, List<Integer>> parameterMap;
    private Map<String, Object> parameters;
    private Mode mode;
    private List<Object> dr;

    /**
     * Create a RestartData for a query
     * @param sqlIn the sql to execute
     * @param parameterMapIn the parameter map
     * @param parametersIn the parameters
     * @param modeIn the mode
     * @param drIn the dr
     */
    public RestartData(String sqlIn, Map<String, List<Integer>> parameterMapIn,
            Map<String, Object> parametersIn, Mode modeIn, List<Object> drIn) {
        this.sql = sqlIn;
        this.parameterMap = parameterMapIn;
        this.parameters = parametersIn;
        this.mode = modeIn;
        this.dr = drIn;
    }

    /**
     * @return the sql
     */
    public String getSql() {
        return sql;
    }

    /**
     * @param sqlIn the sql to set
     */
    public void setSql(String sqlIn) {
        this.sql = sqlIn;
    }

    /**
     * @return the parameterMap
     */
    public Map<String, List<Integer>> getParameterMap() {
        return parameterMap;
    }

    /**
     * @param parameterMapIn the parameterMap to set
     */
    public void setParameterMap(Map<String, List<Integer>> parameterMapIn) {
        this.parameterMap = parameterMapIn;
    }

    /**
     * @return the parameters
     */
    public Map<String, Object> getParameters() {
        return parameters;
    }

    /**
     * @param parametersIn the parameters to set
     */
    public void setParameters(Map<String, Object> parametersIn) {
        this.parameters = parametersIn;
    }

    /**
     * @return the mode
     */
    public Mode getMode() {
        return mode;
    }

    /**
     * @param modeIn the mode to set
     */
    public void setMode(Mode modeIn) {
        this.mode = modeIn;
    }

    /**
     * @return the dr
     */
    public List<Object> getDr() {
        return dr;
    }

    /**
     * @param drIn the dr to set
     */
    public void setDr(List<Object> drIn) {
        this.dr = drIn;
    }

}
