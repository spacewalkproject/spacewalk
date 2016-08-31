<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>

<html:html>
<body>
  <%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>
  <rhn:dialogmenu mindepth="0" maxdepth="1"
      definition="/WEB-INF/nav/kickstart_details.xml"
      renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2>
    <bean:message key="kickstartoptions.jsp.header1" />
  </h2>
  <p>
    <bean:message key="kickstartoptions.jsp.summary" />
  </p>
  <form method="post" class="form-horizontal"
    action="/rhn/kickstart/KickstartOptionsEdit.do">
    <rhn:csrf />
    <c:forEach items="${options}" var="option">
      <div class="form-group">
        <c:choose>
          <c:when test="${option.hasArgs}">
            <label class="col-lg-3 control-label">
              <c:if test="${option.required}">
                <rhn:required-field>${option.name}</rhn:required-field>:
              </c:if>
              <c:if test="${not option.required}">
                ${option.name}:
              </c:if>
            </label>
          </c:when>
          <c:otherwise>
          </c:otherwise>
        </c:choose>
          <div class="col-lg-6">
            <c:choose>
              <c:when test="${option.hasArgs}">
                <div class="input-group">
                  <span class="input-group-addon"> <c:choose>
                      <c:when test="${option.enabled}">
                        <c:set var="enabled" value="checked=\"checked\"" />
                      </c:when>
                      <c:otherwise>
                        <c:set var="enabled" value="" />
                      </c:otherwise>
                    </c:choose>
                    <input type="checkbox" name="${option.name}" value="${option.name}" ${enabled} />
                  </span>
                  <c:choose>
                    <c:when test="${option.name == 'rootpw'}">
                      <input type="text" class="form-control"
                          name="<c:out value="${option.name}" />_txt"
                          value="${option.arg}" size="52" />
                </div>
                <div class="row">
                  <label>
                  <input type="checkbox" name='encrypt_rootpw' value='encrypt_rootpw' id="encrypt_rootpw" />
                    <label for="encrypt_rootpw">
                      <bean:message key="kickstartoptions.jsp.encrypt_rootpw" />
                    </label>
                  </label>
                </div>
              </c:when>
              <c:otherwise>
                <input type="text" class="form-control"
                  name="<c:out value="${option.name}" />_txt"
                  value="${option.arg}" size="64" />
          </div>
        </c:otherwise>
        </c:choose>
        <c:if test="${option.additionalNotesKey != null}">
          <span class="help-block">
            <bean:message key="${option.additionalNotesKey}" />
          </span>
        </c:if>
        </c:when>
        <c:otherwise>
          <div class="col-lg-offset-6 col-lg-3">
            <div class="checkbox">
              <label>
                <input type="checkbox" name="${option.name}" value="${option.name}" ${enabled} />
                  <c:if test="${option.required}">
                    <rhn:required-field>${option.name}</rhn:required-field>
                  </c:if>
                  <c:if test="${not option.required}">
                    ${option.name}
                  </c:if>
              </label>
            </div>
          </div>
        </c:otherwise>
        </c:choose>
      </div>
      </div>
    </c:forEach>
    <div class="form-group">
      <label class="col-lg-3 control-label">
        <bean:message key="kickstartoptions.jsp.customoptions" />
      </label>
      <div class="col-lg-6">
        <textarea rows="8" cols="64" class="form-control" name="customOptions">
          <c:forEach items="${customOptions}" var="option">
		    <c:out value="${option.arguments}" />
		  </c:forEach>
        </textarea>
        <span class="help-block">
          <bean:message key="kickstartoptions.jsp.customoptionsnote" />
        </span>
        <span class="help-block">
          <bean:message key="kickstartoptions.jsp.customoptionstip" />
        </span>
      </div>
    </div>
    <div class="form-group">
      <div class="col-lg-offset-3 col-lg-6">
        <input type="submit" class="btn btn-success"
          value="<bean:message key='kickstartoptions.jsp.updatekickstart'/>" />
      </div>
    </div>
    <rhn:hidden name="ksid" value="${ksdata.id}" />
    <rhn:hidden name="submitted" value="true" />
  </form>
</body>
</html:html>