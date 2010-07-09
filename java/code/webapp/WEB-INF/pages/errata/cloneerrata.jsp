<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:html xhtml="true">
    <body>
<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif"
                 helpUrl="/rhn/help/channel-mgmt/en-US/channel-mgmt-Custom_Errata_Management-Cloning_Errata.jsp">
        <bean:message key="cloneerrata.jsp.erratamanagement"/>
    </rhn:toolbar>

    <h2><bean:message key="cloneerrata.jsp.cloneerrata"/></h2>

    <div class="page-summary">
        <p><bean:message key="cloneerrata.jsp.pagesummary"/></p>
    </div>

    <br/>


    <rl:listset name="groupList" legend="errata">

        <p>
            <bean:message key="cloneerrata.jsp.viewapplicableerrata"/>:
            <select name="channel">
                <c:forEach items="${clonablechannels}" var="option">
                    <option value="<c:out value="${option.value}"/>"
                        <c:if test="${option.value == param.channel}">selected="1"</c:if>>
                        <c:out value="${option.label}"/>
                    </option>
                </c:forEach>
            </select>
            <html:submit>
                <bean:message key="cloneerrata.jsp.view"/>
            </html:submit>
            <br/>

            <c:if test="${param.showalreadycloned == 1}">
                <input type="checkbox" name="showalreadycloned" value="1" checked>
            </c:if>
            <c:if test="${param.showalreadycloned != 1}">
                <input type="checkbox" name="showalreadycloned" value="1">
            </c:if>

            <bean:message key="cloneerrata.jsp.showclonederrata"/>

        </p>

        <rl:list emptykey="cloneerrata.jsp.noerrata">

            <rl:decorator name="PageSizeDecorator"/>
            <rl:decorator name="SelectableDecorator"/>
            <rl:decorator name="ElaborationDecorator"/>

            <rl:selectablecolumn value="${current.selectionKey}"
                                 selected="${current.selected}"
                                 disabled="${not current.selectable}"
                                 styleclass="first-column"/>

            <rl:column headerkey="cloneerrata.jsp.type">
                ${current.advisoryType}
            </rl:column>
            <rl:column headerkey="cloneerrata.jsp.advisory">
                <a href="/rhn/errata/details/Details.do?eid=${current.id}">${current.advisoryName}</a>
            </rl:column>
            <rl:column headerkey="cloneerrata.jsp.synopsis">
                ${current.synopsis}
            </rl:column>
            <rl:column headerkey="cloneerrata.jsp.updated">
                ${current.updateDate}
            </rl:column>
            <rl:column headerkey="cloneerrata.jsp.potentialchannels">
                <c:forEach items="${current.channelMap}" var="map">
                    <a href="/network/software/channels/manage/index.pxt?cid=${map.id}">${map.name}</a><br/>
                </c:forEach>
            </rl:column>
            <rl:column headerkey="cloneerrata.jsp.alreadycloned"
                       styleclass="last-column">
                <c:choose>
                    <c:when test="${current.alreadyCloned}">
                        <bean:message key="yes"/>
                    </c:when>
                    <c:otherwise>
                        <bean:message key="no"/>
                    </c:otherwise>
                </c:choose>
            </rl:column>

        </rl:list>

        <div align="right">
            <rhn:submitted/>
            <hr/>
            <input type="submit"
                   name="dispatch"
                   value='<bean:message key="cloneerrata.jsp.cloneerrata"/>'/>
        </div>

    </rl:listset>

    </body>
</html:html>
