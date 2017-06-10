<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/sm/router/ip">
  <xsl:copy>
    <xsl:text>@localhost@</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/sm/router/pass">
  <xsl:copy>
    <xsl:text>@password@</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/sm/id">
  <xsl:copy>
  <xsl:text>@hostname@</xsl:text>
  </xsl:copy>
</xsl:template>

<xsl:template match="/sm/local[ not (id  = '@hostname@') ]">
  <xsl:copy>
    <xsl:text>
    </xsl:text>
    <id>@hostname@</id>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="/sm/user">
  <xsl:copy>
    <xsl:if test="not(auto-create)">
    <xsl:text>
    </xsl:text>
    <auto-create/>
    <xsl:text>
    </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="@*|node()" />
  </xsl:copy>
</xsl:template>

<xsl:template match="/sm/storage/driver">
  <xsl:copy>
    <xsl:text>sqlite</xsl:text>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
