<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="no" omit-xml-declaration="yes" />
<xsl:preserve-space elements="Connector"/>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/Server/Service[@name='Catalina']/Connector[@port='8080' or @port='8009']">
  <xsl:element name="Connector">
    <xsl:copy-of select="@*" />
    <xsl:attribute name="URIEncoding">UTF-8</xsl:attribute>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
