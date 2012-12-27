<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dc="http://purl.org/dc/terms/" xmlns:dt="http://exslt.org/dates-and-times" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xh="http://www.w3.org/1999/xhtml" xmlns:ars="http://www.adamretter.org.uk" xmlns:urldec="java:java.net.URLDecoder" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:blog="http://www.adamretter.org.uk/blog" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
    <xsl:output exclude-result-prefixes="xsi"/>
    <xsl:param name="uri" as="xs:string"/>
    <xsl:param name="is-authenticated" as="xs:string"/>
    <xsl:param name="show-comments" as="xs:string"/>
    <xsl:param name="recaptcha-public-key"/>
    <xsl:param name="query-string"/>
    <xsl:template match="blog:entry-and-comments">
        <xh:div about="{$uri}">
            <ars:additional>
                <xsl:apply-templates/>
            </ars:additional>
        </xh:div>
    </xsl:template>
    <xsl:template match="blog:entry">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="blog:article">
        <xsl:if test="xs:boolean($is-authenticated) eq true()">
            <xh:a href="{$uri}?edit">
                <xh:input type="button" value="Edit"/>
            </xh:a>
        </xsl:if>
        <xsl:apply-templates/>
        <xh:div class="post-details">
            <xh:p>
                <xh:span property="dc:creator">
                    <xsl:value-of select="@author"/>
                </xh:span> posted
                on <xh:span property="dc:created">
                    <xsl:value-of select="format-dateTime(@timestamp, '[FNn], [D1o] [MNn] [Y] at [H01].[m01] ([z])')"/>
                </xh:span>
                <xsl:if test="@last-updated">
                    <xh:br/>Updated: <xh:span property="dc:modified">
                        <xsl:value-of select="format-dateTime(@last-updated, '[FNn], [D1o] [Y] at [MNn] [H01].[m01] ([z])')"/>
                    </xh:span>
                </xsl:if>
            </xh:p>
        </xh:div>
    </xsl:template>
    <xsl:template match="blog:title">
        <ars:title>
            <xh:a class="blogTitleLink" href="{$uri}" title="{.}" property="dc:title">
                <xsl:value-of select="."/>
            </xh:a>
        </ars:title>
    </xsl:template>
    <xsl:template match="blog:sub-title">
        <ars:sub-title>
            <xsl:copy-of select="node()"/>
        </ars:sub-title>
    </xsl:template>
    <xsl:template match="blog:article-content">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="blog:mini-title">
        <xh:h5>
            <xsl:copy-of select="node()"/>
        </xh:h5>
    </xsl:template>
    <xsl:template match="blog:tags">
        <xh:p class="tags">tags: <xsl:apply-templates/>
        </xh:p>
    </xsl:template>
    <xsl:template match="blog:tag">
        <xsl:variable name="tag" select="."/>
        <xh:a href="blog.xql?tag={$tag}" title="{$tag}" class="tag">
            <xsl:value-of select="$tag"/>
        </xh:a>
    </xsl:template>
    <xsl:template match="blog:comments">
        <xsl:choose>
            <xsl:when test="xs:boolean($show-comments)">
                <xsl:if test="blog:comment">
                    <xh:div id="comments">
                        <xh:h2>
                            <xh:a id="comments">Comments (<xsl:value-of select="count(blog:comment[@pending eq 'false'])"/>)</xh:a>
                        </xh:h2>
                        <xh:br/>
                        <xsl:apply-templates/>
                    </xh:div>
                </xsl:if>
                <xh:div id="addcomment">
                    <xh:h2>
                        <xh:a id="addcomment">Add Comment</xh:a>
                    </xh:h2>
                    <xh:form action="http://www.adamretter.org.uk/blog.xql?comment={$uri}" method="post" id="commentform" onsubmit="return MySubmitForm();">
                        <xsl:if test="ars:get-value-from-query-string('spam') eq 'true'">
                            <xh:div id="spam_warning">
                                <xh:p>Your comment has potentially been recognised as spam, and as
                                    such must be reviewed before it is accepted. I have been
                                    notified, and will endeavour to respond to all legitimate
                                    comments as soon as possible.</xh:p>
                            </xh:div>
                        </xsl:if>
                        <xh:fieldset>
                            <xh:label for="comment_name">Name</xh:label>
                            <xh:br/>
                            <xh:input id="comment_name" name="name" type="text" size="40" value="{ars:get-value-from-query-string('name')}"/>
                            <xh:br/>
                            <xh:label for="comment_email">email address</xh:label> (will not be
                                shown)<xh:br/>
                            <xh:input id="comment_email" name="email" type="text" size="40" value="{ars:get-value-from-query-string('email')}"/>
                            <xh:br/>
                            <xh:label for="comment_website">Website</xh:label>
                            <xh:br/>
                            <xh:input id="comment_website" name="website" type="text" size="60" value="{ars:get-value-from-query-string('website')}"/>
                            <xh:br/>
                            <xh:label for="comment_comments">Comments</xh:label>
                            <xh:br/>
                            <xh:textarea id="comment_comments" name="comments" rows="12" cols="55">
                                <xsl:value-of select="ars:get-value-from-query-string('comments')"/>
                            </xh:textarea>
                            <xh:br/>
                            <xh:div id="asirra_auth">
                                <xh:a id="asirra_logo" href="http://research.microsoft.com/en-us/um/redmond/projects/asirra/">
                                    <xh:img src="http://research.microsoft.com/en-us/um/redmond/projects/asirra/AsirraLogoWithName-Medium.png"/>
                                </xh:a>
                                <xh:script type="text/javascript" src="http://challenge.asirra.com/js/AsirraClientSide.js"/>
                                <xh:script type="text/javascript">
                                    <![CDATA[
                                    // You can control where the big version of the photos appear by
                                    // changing this to top, bottom, left, or right
                                    asirraState.SetEnlargedPosition("top");
                                    
                                    // You can control the aspect ratio of the box by changing this constant
                                    asirraState.SetCellsPerRow(6);
                                    ]]></xh:script>
                                <xh:script type="text/javascript">
                                    <![CDATA[
                                        var passThroughFormSubmit = false;
                                        
                                        function MySubmitForm() {
                                             if(passThroughFormSubmit) {
                                                  return true;
                                             }
                                             // Do site-specific form validation here, then...
                                             Asirra_CheckIfHuman(HumanCheckComplete);
                                             return false;
                                        }
                                        
                                        function HumanCheckComplete(isHuman) {
                                             if(!isHuman) {
                                                  alert("Please correctly identify the cats.");
                                             } else {
                                                  passThroughFormSubmit = true;
                                                  formElt = document.getElementById("commentform");
                                                  formElt.submit();
                                             }
                                        }
                                    ]]></xh:script>
                            </xh:div>
                            <xh:br/>
                            <xh:input type="submit" value="Submit"/>
                        </xh:fieldset>
                    </xh:form>
                </xh:div>
            </xsl:when>
            <xsl:otherwise>
                <xh:p>
                    <xh:a href="{$uri}#comments" class="commentslink">
                        <xsl:value-of select="count(blog:comment[@pending eq 'false'])"/> comments</xh:a> |
                        <xh:a href="{$uri}#addcomment" class="addcommentlink">add
                    comment</xh:a>
                </xh:p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="blog:comment">
        <xsl:if test="xs:boolean($show-comments)">
            <xsl:choose>
                <xsl:when test="@pending eq 'true'">
                    <!-- dont show pending comments -->
                </xsl:when>
                <xsl:otherwise>
                    <xh:div class="comment">
                        <xh:a id="#comment_{@id}"/>
                        <xsl:if test="position() = last()">
                            <xh:a id="lastcomment"/>
                        </xsl:if>
                        <xh:pre>
                            <xsl:value-of select="."/>
                        </xh:pre>
                        <xh:p class="commentmetadata">Posted by <xsl:choose>
                                <xsl:when test="@website">
                                    <xh:a href="{@website}">
                                        <xsl:value-of select="@author"/>
                                    </xh:a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@author"/>
                                </xsl:otherwise>
                            </xsl:choose> on
                                <xsl:value-of select="format-dateTime(@timestamp, ' [FNn], [D1o] [MNn] [Y] at [H01].[m01] ([z])')"/>
                        </xh:p>
                        <xsl:if test="xs:boolean($is-authenticated) eq true()">
                            <xh:form method="post" action="http://www.adamretter.org.uk/blog.xql?entry={$uri}&amp;remove-comment-as-spam=1&amp;comment-id={@id}">
                                <xh:input type="submit" value="Remove as Spam..."/>
                            </xh:form>
                        </xsl:if>
                    </xh:div>
                    <xh:div class="divider2"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    <xsl:template match="xh:*|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:function name="ars:get-value-from-query-string">
        <xsl:param name="name" as="xs:string"/>
        <xsl:analyze-string select="$query-string" regex="{$name}=([^&amp;]*)?">
            <xsl:matching-substring>
                <!-- xsl:value-of select="urldec:decode(regex-group(1))"/ -->
                <xsl:value-of select="ars:decode-uri-component(regex-group(1))"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <!-- Function: doc:hex-to-dec -->
    <!-- Description: Convert hexadecimal xs:string into xs:integer -->
    <!-- Based on ref: http://www.liddicott.com/~sam/?p=52 -->
    <xsl:function name="ars:hex-to-dec" as="xs:integer">
        <xsl:param name="hex" as="xs:string"/>
        <xsl:variable name="length" select="string-length($hex)" as="xs:integer"/>
        <xsl:value-of select="if ($length gt 0) then (                 if ($length lt 2) then (                     string-length(substring-before('0 1 2 3 4 5 6 7 8 9 AaBbCcDdEeFf',$hex)) idiv 2                 ) else (                     ars:hex-to-dec(substring($hex,1,$length - 1))*16 + ars:hex-to-dec(substring($hex,$length))             )) else(0)"/>
    </xsl:function>

    <!-- Function: doc:decode-uri-component -->
    <!-- Description: Decode URI component. -->
    <xsl:function name="ars:decode-uri-component" as="xs:string">
        <xsl:param name="uri-component" as="xs:string"/>
        <xsl:variable name="decoded-component" as="xs:string*">
            <xsl:analyze-string select="$uri-component" regex="%(\d\d)">
                <xsl:matching-substring>
                    <xsl:value-of select="codepoints-to-string(ars:hex-to-dec(regex-group(1)))"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="string-join($decoded-component,'')"/>
    </xsl:function>
</xsl:stylesheet>