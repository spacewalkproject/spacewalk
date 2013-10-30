<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<head>
<script type="text/javascript" src="/javascript/highlander.js"></script>
</head>
<body>

    <h1><i class="fa fa-info-circle"></i><bean:message key="help.jsp.helpdesk"/></h1>

    <ul id="help-url-list">

        <li>
            <a style="font-size:12pt" href=/rhn/help/dispatcher/reference_guide>
                <bean:message key="help.jsp.refguide"/>
            </a>
            <strong><bean:message key="help.jsp.translation"/></strong>
            <br />
            <bean:message key="help.jsp.detailed"/>
        </li>

        <li>
            <a style="font-size:12pt" href=/rhn/help/dispatcher/install_guide>
                <bean:message key="help.jsp.install.title"/>
            </a>
            <strong><bean:message key="help.jsp.translation"/></strong>
            <br />
            <bean:message key="help.jsp.install"/>
        </li>

        <li>
            <a style="font-size:12pt" href=/rhn/help/dispatcher/proxy_guide>
                <bean:message key="help.jsp.proxy.title"/>
            </a>
            <br />
            <bean:message key="help.jsp.proxy"/>
        </li>

        <li>
            <a style="font-size:12pt" href=/rhn/help/dispatcher/client_config_guide>
                <bean:message key="help.jsp.clients.title"/>
            </a>
            <strong><bean:message key="help.jsp.translation"/></strong>
            <br />
            <bean:message key="help.jsp.clients"/>
        </li>

        <li>
            <a style="font-size:12pt" href=/rhn/help/dispatcher/channel_mgmt_guide>
                <bean:message key="help.jsp.channel.title"/>
            </a>
            <strong><bean:message key="help.jsp.translation"/></strong>
            <br />
            <bean:message key="help.jsp.channel"/>
        </li>

        <li>
            <a style="font-size:12pt" href=/rhn/help/dispatcher/release_notes>
                <bean:message key="help.jsp.release.title"/>
            </a>
            <strong><bean:message key="help.jsp.translation"/></strong>
            <br />
        </li>

    </ul>

</body>
</html>
