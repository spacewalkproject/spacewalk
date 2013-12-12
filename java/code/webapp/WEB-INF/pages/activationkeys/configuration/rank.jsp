<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/config-managment" prefix="cfg" %>

<html>
    <head>
        <script src="/javascript/rank_options.js" type="text/javascript"></script>
    </head>
    <body>
        <%@ include file="/WEB-INF/pages/common/fragments/activationkeys/common-header.jspf" %>
        <html:form  method="post"
                    styleClass="form-horizontal"
                    action="/activationkeys/configuration/Rank.do?tid=${param.tid}">
            <rhn:csrf />
            <h2>
                <rhn:icon type="header-channel" />
                <bean:message key="sdc.config.rank.jsp.header"/>
            </h2>
            <c:if test="${not empty param.wizardMode}">
                <h3><bean:message key="ssm.config.rank.jsp.step"/></h3>
                <input type="hidden" name="wizardMode" value="true"/>
            </c:if>
            <p>
                <bean:message key="activation-keys.config.rank.jsp.para1"/>
            </p>
            <p>
                <bean:message key="activation-keys.config.rank.jsp.para2"
                              arg0="${rhn:localize('sdc.config.rank.jsp.update')}"/>
            </p>
            <c:if test="${not empty param.wizardMode}">
                <p>
                    <span class="small-text">
                        <bean:message key="common.config.rank.jsp.warning"
                                      arg0="${rhn:localize('sdc.config.rank.jsp.update')}"/>
                    </span>
                </p>
            </c:if>
            <noscript>
            <p><bean:message key="common.config.rank.jsp.warning.noscript"/></p>
            </noscript>
            <h2><bean:message key="sdc.config.rank.jsp.subscribed_channels"/></h2>
            <%@ include file="/WEB-INF/pages/common/fragments/configuration/rankchannels.jspf" %>
            <div class="form-group">
                <rhn:submitted/>
                <div class="col-lg-offset-3 col-lg-6">
                    <html:hidden property="dispatch" value="${rhn:localize('sdc.config.rank.jsp.update')}"/>
                    <input type=submit name="dispatcher"
                           class="btn btn-success"
                           value="${rhn:localize('sdc.config.rank.jsp.update')}"
                           onclick="handle_ranking_dispatch('ranksWidget','rankedValues','channelRanksForm');"/>
                </div>
            </div>
        </html:form>
    </body>
</html>
