<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<h1><img src="/img/rhn-icon-subscribe_replace.png"> <bean:message key="Distribution Channel Mapping"/></h1>

<rl:listset name="distChannelMap">
<rhn:csrf />

<input type="hidden" name="cid" value="${cid}" />

	<rl:list emptykey="repos.jsp.norepos" alphabarcolumn="os" >

			<rl:decorator name="PageSizeDecorator"/>

                 <rl:column sortable="true"
                   bound="false"
                   headerkey="Operating System"
                   sortattr="os"
                   >
                    ${current.os}
                </rl:column>
                 <rl:column sortable="true"
                   bound="false"
                   headerkey="column.release"
                   sortattr="release"
                   filterattr="release"
                   >
                    ${current.release}
                </rl:column>
                 <rl:column sortable="true"
                   bound="false"
                   headerkey="column.architecture"
                   sortattr="channelArch.name"
                   >
                    ${current.channelArch.name}
                </rl:column>
                 <rl:column sortable="true"
                   bound="false"
                   headerkey="channel.edit.jsp.label"
                   sortattr="channel.label"
                   >
                    ${current.channel.label}
                </rl:column>

	</rl:list>
<!--
	<div align="right">
	  <hr />
		<input type="submit" name="dispatch"
				value="<bean:message key="distchannelmap.jsp.update"/>" />
	</div>
		<rhn:submitted/>
-->

</rl:listset>

</body>
</html>
