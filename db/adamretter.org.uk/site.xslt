<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xh="http://www.w3.org/1999/xhtml"
    xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:ars="http://www.adamretter.org.uk" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:og="http://opengraphprotocol.org/schema/" xmlns:dcterms="http://purl.org/dc/terms/"
    version="2.0">
    <xsl:output doctype-public="-//W3C//DTD XHTML+RDFa 1.0//EN"
        doctype-system="http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd" encoding="UTF-8" indent="yes"
        omit-xml-declaration="no" media-type="text/html" method="xhtml" version="1.0"
        exclude-result-prefixes="xs xh ars"/>
    <xsl:variable name="pathToRoot" select="ars:page/@pathToRoot"/>
    <xsl:template match="ars:page" exclude-result-prefixes="xs xh ars">
        <!--
            
            zenlike1.0 by nodethirtythree design
            http://www.nodethirtythree.com
            
        -->
        <html xml:lang="en">
            <!-- check the profile doesnt break anything!!! -->
            <head profile="http://dublincore.org/documents/2008/08/04/dc-html/">
                <xsl:element name="title">Adam Retter<xsl:if test="@title"> - <xsl:value-of
                            select="@title"/></xsl:if></xsl:element>
                <xsl:element name="meta">
                    <xsl:attribute name="name">DC.title</xsl:attribute>
                    <xsl:attribute name="content">Adam Retter<xsl:if test="@title"> - <xsl:value-of
                                select="@title"/></xsl:if></xsl:attribute>
                </xsl:element>
                <xsl:element name="meta">
                    <xsl:attribute name="name">og:title</xsl:attribute>
                    <xsl:attribute name="content">Adam Retter<xsl:if test="@title"> - <xsl:value-of
                                select="@title"/></xsl:if></xsl:attribute>
                </xsl:element>
                <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/"/>
                <link rel="schema.DCTERMS" href="http://purl.org/dc/terms/"/>
                <link rel="schema.og" href="http://opengraphprotocol.org/schema/"/>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                <meta name="DC.language" scheme="ISO 639-2/T" content="eng"/>
                <meta name="DC.format" content="text/html"/>
                <meta name="DC.type" scheme="DCTERMS.DCMIType" content="Text"/>
                <meta name="DC.publisher" content="Adam Retter"/>
                <meta name="DC.creator" content="Adam Retter"/>
                <meta name="Author" content="Adam Retter"/>
                <meta name="DC.identifier" content="http://www.adamretter.co.uk/"/>
                <meta name="DC.title" content="Adam Retter"/>
                <link rel="stylesheet" type="text/css" href="{$pathToRoot}default.css"/>
                <link rel="icon" type="image/gif" href="{$pathToRoot}images/db1.gif"/>
                <xsl:apply-templates select="ars:head"/>
                <meta property="og:image"
                    content="http://www.adamretter.org.uk/images/adamretter.jpg"/>
                <meta property="og:locality" content="Exeter"/>
                <meta property="og:region" content="Devon"/>
                <meta property="og:country-name" content="UK"/>
                <meta property="og:site_name" content="Adam Retter"/>
                <meta property="og:type" content="website"/>
                <meta property="og:type" content="blog"/>
                <meta property="og:email" content="adam.retter@googlemail.com"/>
                <meta property="og:phone_number" content="+44 20 3239 7236"/>
            </head>
            <body>
                <div id="upbg"/>
                <div id="outer">
                    <div id="header">
                        <div id="headercontent">
                            <h1>Adam Retter</h1>
                            <h2>&lt;!-- my personal website --&gt;</h2>
                        </div>
                    </div>
                    <!--
                    <form method="get" action="{$pathToRoot}search.xql">
                        <div id="search">
                            <xsl:variable name="keywords" select="ars:content/ars:search/@keywords"/>
                            <input type="text" class="text" maxlength="64" name="keywords" value="{$keywords}"/>
                            <input type="submit" class="submit" value="Search"/>
                        </div>
                    </form>
                    -->
                    <div id="headerpic"/>
                    <div id="menu">
                        <ul>
                            <li>
                                <a href="{$pathToRoot}home.xml" title="Home page"
                                    class="{if(@ars:name eq 'Home')then 'active' else 'unactive'}"
                                    >Home</a>
                            </li>
                            <li>
                                <a href="{$pathToRoot}blog.xql" title="Blog"
                                    class="{if(@ars:name eq 'Blog')then 'active' else 'unactive'}"
                                    >Blog</a>
                            </li>
                            <li>
                                <a href="{$pathToRoot}presentations.xml" title="Presentations"
                                    class="{if(@ars:name eq 'Presentations')then 'active' else 'unactive'}"
                                    >Presentations</a>
                            </li>
                            <xsl:apply-templates select="ars:menu-item"/>
                        </ul>
                    </div>
                    <div id="menubottom"/>
                    <xsl:apply-templates
                        select="@*[local-name(.) ne 'title']|node()[node-name(.) ne QName('http://www.adamretter.org.uk','head')]"/>
                    <div id="footer">
                        <div class="left"><a rel="license"
                                href="http://creativecommons.org/licenses/by-nc-nd/3.0/"><img
                                    alt="Creative Commons License" style="border-width:0"
                                    src="http://i.creativecommons.org/l/by-nc-nd/3.0/88x31.png"
                                /></a><span about="" resource="http://www.w3.org/TR/rdfa-syntax"
                                rel="dcterms:conformsTo"><a
                                    href="http://validator.w3.org/check?uri=referer"><img
                                        src="http://www.w3.org/Icons/valid-xhtml-rdfa"
                                        alt="Valid XHTML + RDFa" height="31" width="88"
                                        style="border: 0;"/></a></span><a
                                href="http://jigsaw.w3.org/css-validator/validator?uri=http://www.exquery.org/styles.css"
                                    ><img src="{$pathToRoot}images/valid-css.gif" alt="Valid CSS!"
                                    style="border: 0;"/></a><a href="http://dublincore.org/"
                                title="Dublin Core Meadata Initiative"><img
                                    src="{$pathToRoot}images/dcuh_88x31.gif"
                                    alt="Dublin Core Used Here" style="border: 0;"/></a><a
                                href="http://www.ogp.me/" title="Open Graph Protocol"><img
                                    src="{$pathToRoot}images/ogp_88x31.png"
                                    alt="Open Graph Protocol Used Here" style="border: 0;"
                            /></a><br/> This <span href="http://purl.org/dc/dcmitype/Text"
                                rel="dc-legacy:type">work</span> is licensed under a <a
                                rel="license"
                                href="http://creativecommons.org/licenses/by-nc-nd/3.0/">Creative
                                Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License</a>. </div>
                        <div class="right">
                            <div><a href="http://www.openindiana.org" title="Open Indiana">Open
                                    Indiana</a> hosting by: <a href="http://www.entic.net"
                                    >Entic.net</a></div>
                            <div>Powered by: <a href="http://www.nginx.net">Nginx</a> + <a
                                    href="http://www.exist-db.org">eXist-db</a></div>
                            <div>Design by <a href="http://www.nodethirtythree.com/">NodeThirtyThree
                                    Design</a></div>
                        </div>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="@ars:name"/>
    <xsl:template match="@pathToRoot"/>
    <xsl:template match="ars:head" exclude-result-prefixes="#all">
        <xsl:apply-templates select="xh:*"/>
    </xsl:template>
    <xsl:template match="ars:menu-item" exclude-result-prefixes="#all">
        <li>
            <a href="{@href}" title="{@title}">
                <xsl:value-of select="."/>
            </a>
        </li>
    </xsl:template>
    <xsl:template match="ars:content" exclude-result-prefixes="#all">
        <div id="content">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="ars:main" exclude-result-prefixes="#all">
        <div class="normalcontent">
            <h3>
                <strong>
                    <xsl:apply-templates select="ars:title"/>
                </strong>
            </h3>
            <div class="details">
                <xsl:value-of select="ars:sub-title"/>
            </div>
            <div class="contentarea">
                <xsl:apply-templates select="xh:*|ars:additionals"/>
            </div>
        </div>
        <div class="divider1"/>
    </xsl:template>
    <xsl:template match="ars:summary">
        <xsl:apply-templates select="xh:*"/>
    </xsl:template>
    <xsl:template match="ars:additionals" exclude-result-prefixes="#all">
        <div id="primarycontainer">
            <div id="primarycontent">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="ars:additional" exclude-result-prefixes="#all">
        <div class="post">
            <h4>
                <xsl:apply-templates select="ars:title"/>
            </h4>
            <div class="contentarea">
                <div class="details">
                    <xsl:apply-templates select="ars:sub-title"/>
                </div>
                <xsl:apply-templates select="xh:*"/>
                <div style="clear: both;"/>
                <!--
                    <ul class="controls">
                    <li><a href="#" class="printerfriendly">Printer Friendly</a></li>
                    <li><a href="#" class="comments">Comments (18)</a></li>
                    <li><a href="#" class="more">Read More</a></li>
                    </ul>
                -->
            </div>
        </div>
        <div class="divider2"/>
    </xsl:template>
    <xsl:template match="ars:extra-nav" exclude-result-prefixes="#all">
        <div id="secondarycontent">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="ars:highlight" exclude-result-prefixes="#all">
        <div class="box">
            <h4>
                <xsl:value-of select="ars:title"/>
            </h4>
            <div class="contentarea">
                <xsl:apply-templates select="xh:*"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="ars:links" exclude-result-prefixes="#all">
        <div>
            <h4>
                <xsl:value-of select="ars:title"/>
            </h4>
            <div class="contentarea">
                <xsl:apply-templates select="xh:*|text()"/>
            </div>
        </div>
        <!--
        <div class="divider2"/>
        -->
    </xsl:template>
    <!-- rewrite img src to relative path -->
    <xsl:template match="xh:img | xh:a | xh:form">
        <xsl:element name="{local-name()}">
            <xsl:for-each select="@*">
                <xsl:choose>
                    <xsl:when
                        test="local-name(.) = ('src','href','action') and not(starts-with(., 'http://'))">
                        <xsl:variable name="uri" select="."/>
                        <xsl:attribute name="{local-name(.)}" select="concat($pathToRoot, $uri)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="xh:*[not(local-name(.) = ('img','a'))]">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
</xsl:stylesheet>