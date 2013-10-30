<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html >
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="spacewalk-icon-software-channels"
	miscUrl="${url}"
	miscAcl="user_role(org_admin)"
	miscText="${text}"
	miscImg="${img}"
	miscAlt="${text}"
	imgAlt="users.jsp.imgAlt">
    ${entitlementName}
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="3" definition="/WEB-INF/nav/softwareentitlementtabs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="softwareEntitlementDetails.header.accessGranted"/></h2>

<bean:message key="softwareEntitlementDetails.header.accessGrantedDescription" arg0="${entitlementName}"/>

<rl:listset name="channelSet">
    <rhn:csrf />
    <rhn:submitted />
    <rl:list dataset="pageList"
             width="100%"
             name="pageList"
             styleclass="list"
             emptykey="softwareEntitlementDetails.noChannelsFound">

        <rl:column bound="false"
            sortable="false"
            headerkey="softwareEntitlementDetails.header.channelName">

            <rhn:require	acl="can_access_channel(${current.id});" >
	               <a href="/rhn/channels/ChannelDetail.do?cid=${current.id}">
	                	${current.name}
			</a>
            </rhn:require>

            <rhn:require	acl="not can_access_channel(${current.id});" >
				${current.name}
            </rhn:require>

        </rl:column>

        <rl:column bound="false"
            sortable="false"
            attr="packageCount"
            headerkey="softwareEntitlementDetails.header.packages">
            <rhn:require	acl="can_access_channel(${current.id});" >
	               <a href="/rhn/channels/ChannelPackages.do?cid=${current.id}">
	                	${current.packageCount}
			</a>
            </rhn:require>

            <rhn:require	acl="not can_access_channel(${current.id});" >
				${current.packageCount}
            </rhn:require>
        </rl:column>


    </rl:list>
</rl:listset>

</body>
</html:html>

