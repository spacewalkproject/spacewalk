<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/channel/manage/manage_channel_header.jspf" %>
        <h2>
            <rhn:icon type="header-errata" title="errata.common.errataAlt" />
            <bean:message key="channel.jsp.errata.clone.title"/>
        </h2>

        <p><bean:message key="channel.jsp.errata.clone.summary"/></p>

        <rl:listset name="errataSet">
            <rhn:csrf />
            <rhn:submitted />
            <rhn:hidden name="cid" value="${cid}" />

            <%@ include file="/WEB-INF/pages/common/fragments/errata/selectableerratalist.jspf" %>

            <div class="text-right">
                <hr />
                <input class="btn btn-default"
                       type="submit"
                       name="dispatch"
                       value="<bean:message key='channel.jsp.errata.clone.button'/>">
            </div>

        </rl:listset>

    </body>
</html>
