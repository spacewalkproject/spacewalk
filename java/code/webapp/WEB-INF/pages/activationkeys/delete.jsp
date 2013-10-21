<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<html:html>
    <body>
        <rhn:toolbar base="h1" icon="icon-key"
                     imgAlt="activation-keys.common.alt"
                     helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-systems-activation-keys"
                     >
            <bean:message key ="activation-key.jsp.delete.title"/>
        </rhn:toolbar>
        <p><bean:message key="activation-key.jsp.delete.para" arg0="/rhn/activationkeys/List.do"/></p>
        <p><bean:message key="activation-key.jsp.delete.warning" /></p>
        <form action="/rhn/activationkeys/Delete.do" class="form-horizontal"
              id ="delete_confirm" name = "delete_confirm" method="POST">
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="kickstart.activationkeys.jsp.description"/>:
                </label>
                <div class="col-lg-6">
                    <div class="form-control">
                        <c:out value="${requestScope.activationkey.note}"/>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <label class="col-lg-3 control-label">
                    <bean:message key="kickstart.activationkeys.jsp.key"/>
                </label>
                <div class="col-lg-6">
                    <div class="form-control">
                        <c:out value="${requestScope.activationkey.key}"/>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <input type="hidden" name="tid" value="${param.tid}"/>
                    <rhn:csrf />
                    <input type="submit" name="dispatch" class="btn btn-success"
                           value="${rhn:localize('activation-key.jsp.delete-key')}" align="top" />
                    <rhn:submitted/>
                </div>
            </div>
        </form>
    </body>
</html:html>
