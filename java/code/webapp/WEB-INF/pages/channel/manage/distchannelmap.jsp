<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<rhn:toolbar base="h1" icon="fa-retweet"
               creationUrl="DistChannelMapEdit.do"
               creationType="distchannelmap"
               iconAlt="info.alt.img">
  <bean:message key="Distribution Channel Mapping"/>
</rhn:toolbar>

<div class="page-summary">
<p><bean:message key="distchannelmap.jsp.summary"/></p>
</div>


<rl:listset name="distChannelMap">
<rhn:csrf />

<input type="hidden" name="cid" value="${cid}" />

	<rl:list emptykey="distchannelmap.jsp.empty" alphabarcolumn="os" >

			<rl:decorator name="PageSizeDecorator"/>

                 <rl:column sortable="true"
                   bound="false"
                   headerkey="Operating System"
                   sortattr="os"
                   >
                     <a href="/rhn/channels/manage/DistChannelMapEdit.do?dcm=${current.id}">${current.os}</a>
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
                   <a href="/rhn/channels/ChannelDetail.do?cid=${current.channel.id}">
                    ${current.channel.label}
                   </a>
                </rl:column>
                 <rl:column
                   bound="false"
                   headerkey="org.specific"
                   >
                   <c:choose>
                     <c:when test="${current.org != null}">
                       <i class="fa fa-check text-success"></i>
                     </c:when>
                     <c:otherwise>
                       <i class="fa fa-circle-o"></i>
                     </c:otherwise>
                   </c:choose>
                </rl:column>
	</rl:list>
<!--
	<div class="text-right">
	  <hr />
		<input type="submit" name="dispatch"
				value="<bean:message key='distchannelmap.jsp.update'/>" />
	</div>
		<rhn:submitted/>
-->

</rl:listset>

</body>
</html>
