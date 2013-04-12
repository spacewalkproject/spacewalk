<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
<xsl:preserve-space elements="Connector"/>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/Server/Service[@name='Catalina']/Connector[@port='8009' and (not(@address) or @address='127.0.0.1')]">
  <xsl:element name="Connector">
    <xsl:copy-of select="@*" />
    <xsl:attribute name="URIEncoding">UTF-8</xsl:attribute>
    <xsl:attribute name="address">127.0.0.1</xsl:attribute>
  </xsl:element>
  <xsl:if test="not(../Connector[@port='8009' and @address='::1'])">
  <xsl:copy-of select="preceding-sibling::node()[last()][self::text()]" />
  <xsl:element name="Connector">
    <xsl:copy-of select="@*" />
    <xsl:attribute name="URIEncoding">UTF-8</xsl:attribute>
    <xsl:attribute name="address">::1</xsl:attribute>
  </xsl:element>
  </xsl:if>
</xsl:template>

<xsl:template match="/Server/Service[@name='Catalina']/Connector[@port='8009' and @address='::1']">
  <xsl:element name="Connector">
    <xsl:copy-of select="@*" />
    <xsl:attribute name="URIEncoding">UTF-8</xsl:attribute>
    <xsl:attribute name="address">::1</xsl:attribute>
  </xsl:element>
</xsl:template>

<xsl:template match="/Server/Service[@name='Catalina']/Connector[@port='8080']">
  <xsl:element name="Connector">
    <xsl:copy-of select="@*" />
    <xsl:attribute name="URIEncoding">UTF-8</xsl:attribute>
    <xsl:attribute name="address">127.0.0.1</xsl:attribute>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
