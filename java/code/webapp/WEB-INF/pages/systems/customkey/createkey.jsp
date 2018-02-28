<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html>
    <body>
        <rhn:toolbar base="h1" icon="header-activation-key"
        helpUrl="">
            <bean:message key="system.jsp.customkey.createtitle"/>
        </rhn:toolbar>

        <p>
            <bean:message key="system.jsp.customkey.createmsg"/>
        </p>
        <form action="/rhn/systems/customdata/CreateCustomKey.do"
              class="form-horizontal"
              name="edit_token" method="post">
            <rhn:csrf />
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="system.jsp.customkey.keylabel"/>:
                </label>
                <div class="col-lg-6">
                    <input type="text" name="label"
                           length="64" size="30" class="form-control"
                           maxlength="64"
                           value="<c:out value="${old_label}" />"/>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label" for="descr">
                    <bean:message key="system.jsp.customkey.description"/>:
                </label>
                <div class="col-lg-6">
                    <textarea id="descr" wrap="virtual" rows="6" cols="50"
                              class="form-control"
                              maxlength="4000"
                              name="description"><c:out value="${old_description}" /></textarea>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <button type="submit" class="btn btn-success"
                            name="CreateKey"
                            value="Create Key" />
                        <bean:message key="keycreate.jsp.submit" />
                    </button>
                            <rhn:submitted/>
                </div>
            </div>
        </form>
    </body>
</html:html>
