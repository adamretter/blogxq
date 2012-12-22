xquery version "1.0";

import module namespace datetime = "http://exist-db.org/xquery/datetime";
import module namespace mail = "http://exist-db.org/xquery/mail";
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace response = "http://exist-db.org/xquery/response";
import module namespace session = "http://exist-db.org/xquery/session";
import module namespace transform = "http://exist-db.org/xquery/transform";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

declare namespace ars = "http://www.adamretter.org.uk";
declare namespace blog = "http://www.adamretter.org.uk/blog";

declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace xh ="http://www.w3.org/1999/xhtml";

import module namespace config = "http://www.adamretter.org.uk/config" at "xmldb:exist:///db/adamretter.org.uk/config.xqm";
(: import module namespace recaptcha = "http://www.exist-db.org/xquery/util/recapture" at "xmldb:exist:///db/util/recapture.xqm"; :)
import module namespace asirra = "http://asirra.com/xquery/api" at "xmldb:exist:///db/util/asirra.xqm";
import module namespace akismet = "http://akismet.com/xquery/api" at "xmldb:exist:///db/util/akismet.xqm";

declare variable $local:akismet-api-key := "20139c84c379f20fb691267cee79e557";

declare option exist:serialize "method=xhtml";

declare function local:blog-login() as element(ars:page)
{
    <ars:page ars:name="Blog">
        <ars:content>
            <ars:main>
                <ars:title>Blog</ars:title>
                <ars:sub-title>Login</ars:sub-title>
                <xh:div>
                    <xh:form method="post" action="?login">
                        <xh:label for="uid">Username: </xh:label>
                        <xh:input type="text" id="uid" name="uid"/>
                        <xh:br/>
                        <xh:label for="pwd">Password: </xh:label>
                        <xh:input type="password" id="pwd" name="pwd"/>
                        <xh:br/>
                        <xh:input type="submit" value="Login"/>
                    </xh:form>
                </xh:div>
            </ars:main>
        </ars:content>
    </ars:page>
};

declare function local:blog-do-login($username as xs:string, $password as xs:string) as element(ars:page)
{
    if(xmldb:login("/db/adamretter.org.uk/blog/entries", $username, $password, true()))then
    (
        response:redirect-to(xs:anyURI("http://www.adamretter.org.uk/blog.xql"))    
    )
    else
    (
        response:redirect-to(xs:anyURI("http://www.adamretter.org.uk/blog.xql?failed"))
    )
};

declare function local:blog-do-logout() as element(ars:page)
{
    session:clear(),
    session:invalidate(),
    response:redirect-to(xs:anyURI("http://www.adamretter.org.uk/blog.xql"))
};

declare function local:is-comment-spam($new-comment-id as xs:string) as xs:boolean
{
    akismet:comment-check(
        $local:akismet-api-key, 
        <akismet:comment>
            <akismet:blog>http://www.adamretter.org.uk/blog.xql</akismet:blog>
            <akismet:user_ip>{request:get-header("X-Real-IP")}</akismet:user_ip>
            <akismet:user_agent>{request:get-header("User-Agent")}</akismet:user_agent>
            <akismet:referrer>{request:get-header("Referer")}</akismet:referrer>
            <akismet:permalink>http://www.adamretter.org.uk/{request:get-parameter("comment",())}#comment_{$new-comment-id}</akismet:permalink>
            <akismet:comment_type>comment</akismet:comment_type>
            <akismet:comment_author>{request:get-parameter("name", ())}</akismet:comment_author>
            {
                if(request:get-parameter("email",()))then
                    <akismet:comment_author_email>{request:get-parameter("email", ())}</akismet:comment_author_email>
                else(),
                
                if(request:get-parameter("website",()))then
                    <akismet:comment_author_url>{ request:get-parameter("website", ()) }</akismet:comment_author_url>
                else()
            }
            <akismet:comment_content>{request:get-parameter("comments", ())}</akismet:comment_content>       
        </akismet:comment>
    )
};

(: marks a comment as spam, and returns the id of the entry to which the comment was associated :)
declare function local:mark-comment-as-spam($comment-id as xs:string) as xs:string {
    let $comment := fn:collection("/db/adamretter.org.uk/blog/entries/comments")/blog:comment[@id eq $comment-id],
    $entry := fn:collection("/db/adamretter.org.uk/blog/entries")/blog:entry[@id eq $comment/@entry-id] return
    
        let $spam := akismet:submit-spam(
            $local:akismet-api-key,
            <akismet:comment>
                <akismet:blog>http://www.adamretter.org.uk/blog.xql</akismet:blog>
                <akismet:user_ip>{string($comment/@ip)}</akismet:user_ip>
                <akismet:user_agent>{string($comment/@user-agent)}</akismet:user_agent>
                <akismet:referrer>{string($comment/@referrer) }</akismet:referrer>
                <akismet:permalink>http://www.adamretter.org.uk/blog/entries/{fn:replace(fn:document-uri(fn:root($entry)), ".*/", "")}#comment_{$comment-id}</akismet:permalink>
                <akismet:comment_type>comment</akismet:comment_type>
                <akismet:comment_author>{string($comment/@author)}</akismet:comment_author>
                {
                    if($comment/@email)then
                        <akismet:comment_author_email>{string($comment/@email)}</akismet:comment_author_email>
                    else(),
                    
                    if($comment/@website)then
                        <akismet:comment_author_url>{ string($comment/@website) }</akismet:comment_author_url>
                    else()
                }
                <akismet:comment_content>{$comment/text()}</akismet:comment_content>       
            </akismet:comment>
        ) return
        
            if($spam) then
                $entry/@id
            else
                fn:error(fn:concat("Could not mark comment '", $comment-id, "' as spam"))
};

declare function local:remove-comment-as-spam($comment-id as xs:string) {
    (: mark the comment as spam :)
    let $entry-id := local:mark-comment-as-spam($comment-id) return
    
        (: delete the comment :)
        let $comment-uri := fn:document-uri(fn:root(fn:collection("/db/adamretter.org.uk/blog/entries/comments")/blog:comment[@id eq $comment-id])) return
            let $removed := xmldb:remove(fn:replace($comment-uri, "(.*)/.*", "$1"), fn:replace($comment-uri, ".*/", "")) return
            
                (: redirect back to the entry :)
                response:redirect-to(xs:anyURI(concat("http://www.adamretter.org.uk/", request:get-parameter("entry",()), "#lastcomment")))
};

declare function local:create-comment($entry-uri as xs:anyURI, $pending-status as xs:boolean, $new-comment-id as xs:string) as element(blog:comment)
{
    let $entry := doc(concat("/db/adamretter.org.uk/", $entry-uri))/blog:entry return
    
        element blog:comment {
            attribute pending { $pending-status },
            attribute timestamp { current-dateTime() },
            attribute ip { request:get-header("X-Real-IP") },
            attribute user-agent { request:get-header("User-Agent") },
            attribute referrer { request:get-header("Referer") },
            attribute author { request:get-parameter("name", ()) },
            if(request:get-parameter("email",()))then
            (
                attribute email { request:get-parameter("email", ()) }
            )else(),
            if(request:get-parameter("website",()))then
            (
                attribute website { request:get-parameter("website", ()) }
            )else(),
            attribute id { $new-comment-id },
            attribute entry-id { $entry/@id },
            text { request:get-parameter("comments", ()) }
        }
};

declare function local:save-comment($entry-uri as xs:anyURI, $comment as element(blog:comment)) as xs:string
{
    xmldb:store("/db/adamretter.org.uk/blog/entries/comments", fn:concat($comment/@id, ".xml"), $comment)
};

declare function local:send-new-comment-notification-mail($comment-uri as xs:string) as xs:boolean {
    mail:send-email(
        <mail>
            <from>adam.retter@googlemail.com</from>
            <to>adam.retter@googlemail.com</to>
            <subject>New Comment on your blog!</subject>
            <message>
                <text>There is a new comment on your blog. See {$comment-uri}</text>
            </message>
        </mail>,
        "localhost",
        "UTF-8"
    )
};

declare function local:send-new-spam-comment-notification-mail($comment-uri) as xs:boolean {
    mail:send-email(
        <mail>
            <from>adam.retter@googlemail.com</from>
            <to>adam.retter@googlemail.com</to> 
            <subject>Spam Comment added to your blog!</subject>
            <message>
                <text>A new comment was added to your blog, but Akismet recognised it as Spam. See {$comment-uri}</text>
            </message>
        </mail>,
        "localhost",
        "UTF-8"
    )
};

declare function local:get-atom-feed() as element(atom:feed)
{
    let $all-blog-entries := local:get-blog-entries("published") return
    
        <feed xmlns="http://www.w3.org/2005/Atom" xmlns:xh="http://www.w3.org/1999/xhtml">
            <generator uri="http://www.adamretter.org.uk/blog.xql" version="1.0">Adam Retters XQuery Blog Code</generator>
            <title>Adam Retter's Blog</title>
            <subtitle type="xhtml"><xh:a href="http://www.adamretter.org.uk/blog.xql">http://www.adamretter.org.uk/blog.xql</xh:a></subtitle>
            <link rel="alternate" type="text/html" hreflang="en" href="http://www.adamretter.org.uk/blog.xql"/>
            <link rel="self" type="application/atom+xml" href="http://www.adamretter.org.uk/blog.xql?atom"/>          
            <updated>
            {
                (
                    for $last-updated in $all-blog-entries/blog:article/@last-updated order by $last-updated descending return
                        string($last-updated)
                )[1]
            }
            </updated>
            <author>
                <name>Adam Retter</name>
                <uri>http://www.adamretter.org.uk</uri>
            </author>
            <id>tag:www.adamretter.org.uk,2009-07-22:/blog.xql</id>
            {
                for $blog-entry in $all-blog-entries order by xs:dateTime($blog-entry/blog:article/@last-updated) descending return
                    local:get-atom-entry($blog-entry)
            }
        </feed>
};

declare function local:get-atom-entry($blog-entry as element(blog:entry)) as element(atom:entry)
{
    <entry xmlns="http://www.w3.org/2005/Atom">
        <title>{$blog-entry/blog:article/blog:title/text()}</title>
        <link rel="alternate" type="text/html" hreflang="en" href="{local:db-uri-to-web-uri(document-uri(root($blog-entry)))}"/>
        <id>tag:www.adamretter.org.uk,{datetime:format-dateTime($blog-entry/blog:article/@timestamp, 'yyyy-MM-dd')}:{replace(document-uri(root($blog-entry)), '/db/adamretter.org.uk', '')}</id>
        {
            if($blog-entry/blog:article/@last-updated)then
            (
                <updated>{string($blog-entry/blog:article/@last-updated)}</updated>
            )else
            (
                <updated>{string($blog-entry/blog:article/@timestamp)}</updated>
            )
        }
        <published>{string($blog-entry/blog:article/@timestamp)}</published>
        <author>
            <name>{string($blog-entry/blog:article/@author)}</name>
        </author>
        {
            for $tag in $blog-entry/blog:tags/blog:tag return
                <category term="{$tag/text()}"/>
        }
        <summary type="xhtml">
            <xh:div>{ local:reduce-words($blog-entry/blog:article/blog:article-content/xh:p, 100) }</xh:div> 
        </summary>
    </entry>
};

declare function local:reduce-words($paras as element(xh:p)*, $word-count as xs:integer)
{
    if(not(empty($paras)) and $word-count gt 0)then
    (
        let $para := $paras[1] return
            let $words := tokenize($para/text(), " ") return
                if(count($words) gt $word-count)then
                (
                    (: TODO expand this to include nodes and text :)
                    <xh:p>{string-join(subsequence($words, 0, $word-count), " ")}...</xh:p>
                )
                else
                (
                    $para,
                    local:reduce-words(subsequence($paras, 2, count($paras)-1), ($word-count - count($words)))
                )
    )else()
};

declare function local:edit-page($entry-uri as xs:anyURI, $resources-path as xs:string?) as element(ars:page)
{
    (: TODO when this betterForm is ready replace with an XForm that can just be PUT into the collecton! :)
    
    let $entry := doc($entry-uri)/blog:entry return
    
        <ars:page ars:name="Blog">
                {
                    if(not(empty($resources-path)))then
                    (
                        attribute pathToRoot { $resources-path }
                    )else(),
                    
                    attribute title {
                        concat("Blog - ", $entry/blog:article/blog:title)
                    }
                }
                <ars:head>
                    <xh:script type="text/javascript" src="{$resources-path}/blog/ckeditor/ckeditor.js"></xh:script>
                    <xh:script type="text/javascript" src="{$resources-path}/blog/jquery-1.4.2.min.js"></xh:script>                    
                </ars:head>
                <ars:content>
                    <ars:main>
                        <ars:title>Blog</ars:title>
                        <ars:sub-title>Edit</ars:sub-title>
                        <xh:form action="?save" method="post">
                            <xh:label for="title">Title</xh:label><xh:br/><xh:input type="text" id="title" name="title" value="{$entry/blog:article/blog:title}" size="100"/><xh:br/>
                            <xh:br/>
                            <xh:label for="subTitle">Sub Title</xh:label><xh:br/><xh:input type="text" id="subTitle" name="sub-title" value="{$entry/blog:article/blog:sub-title}" size="75"/><xh:br/>
                            <xh:br/>
                            <xh:label for="content">Article Content</xh:label><xh:br/>
                            <xh:textarea class="ckeditor" cols="80" id="content" name="content" rows="50">{$entry/blog:article/blog:article-content/node()}</xh:textarea><xh:br/>
                            <xh:div id="tagListContainer">
                                <xh:label for="tagList">Tags</xh:label><xh:br/>
                                <xh:ul id="tagList" class="checkboxList">
                                    {
                                        for $tag at $i in $entry/blog:tags/blog:tag order by $tag ascending return
                                            <xh:li>
                                                <xh:input id="tag_{$i}" type="checkbox" name="tag" value="{$tag}" checked="checked"/>
                                                <xh:label for="tag_{$i}">{$tag/text()}</xh:label>
                                            </xh:li>
                                    }
                                </xh:ul>
                            </xh:div>
                            <xh:label for="newTag">New Tag</xh:label><xh:br/>
                            <xh:input id="newTag" type="text"/><xh:input id="addTag" type="button" value="add"/>
                            <xh:script type="text/javascript">{ text {
                                "$(document).ready(function(){
                                 $('#addTag').click(function(event){
                                 
                                    var uuid = (new Date()).getTime();
                                    var li = document.createElement('li');
                                    
                                    var input = document.createElement('input');
                                    input.setAttribute('id', 'tag_' + uuid);
                                    input.setAttribute('type', 'checkbox');
                                    input.setAttribute('name', 'tag');
                                    input.setAttribute('value', $('#newTag').val());
                                    input.setAttribute('checked', 'checked');
                                    
                                    var label = document.createElement('label');
                                    label.setAttribute('for', 'tag_' + uuid);
                                    label.innerText = $('#newTag').val();
                                    
                                    li.appendChild(input);
                                    li.appendChild(label);
                                 
                                    $('#tagList').append(li);
                                 });
                               });
                               "
                            }}</xh:script>
                            <xh:input type="submit" value="Save"/>
                        </xh:form>
                    </ars:main>
                </ars:content>
            </ars:page>
};

declare function local:save-page($entry-uri as xs:anyURI, $resources-path as xs:string?) as element(ars:page)
{
    let $entry := doc($entry-uri)/blog:entry return (
        update value $entry/blog:article/blog:title with request:get-parameter("title",()),
        update value $entry/blog:article/blog:sub-title with request:get-parameter("sub-title",()),
        update replace $entry/blog:article/blog:article-content with <blog:article-content>{util:parse(concat("<div xmlns='http://www.w3.org/1999/xhtml'>", request:get-parameter("content",()), "</div>"))/xh:div/child::node()}</blog:article-content>,
        update replace $entry/blog:tags with
            <blog:tags>{
                for $tag in request:get-parameter("tag",()) return
                    <blog:tag>{$tag}</blog:tag>
            }</blog:tags>,
        if($entry/blog:article/@last-updated)then
        (
            update value $entry/blog:article/@last-updated with current-dateTime()
        )
        else
        (
            update insert attribute last-updated { current-dateTime() } into $entry/blog:article 
        )
    ),
    
    let $page := local:page(util:function(xs:QName("local:entry-filter"), 1), $resources-path) return
        transform:stream-transform($page, doc("/db/adamretter.org.uk/site.xslt"), ())
};

declare function local:is-authenticated() as xs:boolean
{
    not(empty(session:get-attribute('_eXist_xmldb_user')))
};

declare function local:get-comments-for-entries($entries as element(blog:entry)+) as element(blog:comment)* {
    collection("/db/adamretter.org.uk/blog/entries/comments")/blog:comment[@entry-id = $entries/@id]
};

declare function local:page($filter-function, $resources-path as xs:string?) as element(ars:page)
{
    let $blog-entries := local:get-blog-entries(request:get-parameter("status", "published")),
    $filtered-entries := util:call($filter-function, $blog-entries),
    $filtered-entries-count := count($filtered-entries) return


        <ars:page ars:name="Blog">
            {
                if(not(empty($resources-path)))then
                (
                    attribute pathToRoot { $resources-path }
                )else(),
                
                attribute title {
                    if($filtered-entries-count eq 1)then
                    (
                        concat("Blog - ", $filtered-entries/blog:article/blog:title)
                    )
                    else
                    (
                        "Blog"
                    )
                }
            }
            <ars:head>
                <xh:link rel="alternate" type="application/atom+xml" href="?atom"/>
                {
                    (: work out the dateTime of the thing that was last modified :)
                    let $articles-last-modified := fn:max($filtered-entries/blog:article/xs:dateTime(@last-updated)),
                    
                    $comments-for-all-entries := local:get-comments-for-entries($filtered-entries),
                    $comments-last-modified :=
                        if(fn:empty($comments-for-all-entries))then
                            xs:dateTime("1970-01-01T00:00:00.000")
                        else
                            fn:max($comments-for-all-entries/xs:dateTime(@timestamp))
                    return
                        <xh:meta name="DCTERMS.modified" scheme="DCTERMS.W3CDTF" content="{fn:max(($articles-last-modified, $comments-last-modified))}"/>
                }
            </ars:head>
            <ars:content>
                <ars:main>
                    <ars:title>Blog</ars:title>
                    <ars:sub-title>Ponderings of a kind</ars:sub-title>
                    <xh:p>This is my own personal blog, each article is an XML document and the code powering it is hand cranked in XQuery and XSLT. It is fairly simple and has evolved only as I have needed additional functionality. I plan to Open Source the code once it is a bit more mature, however if you would like a copy in the meantime drop me a line.</xh:p>
                    <xh:a href="?atom" title="Atom Feed" alt="Atom Feed">
                        <xh:img src="{$resources-path}/blog/images/app/atom.jpg" style="border: 0" alt="Atom Feed" title="Atom Feed"/>
                    </xh:a>
                </ars:main>
                <ars:additionals>
                {
                    let $show-comments := ($filtered-entries-count eq 1) return
                        if(empty($filtered-entries))then
                        (
                            <xh:p>Error - No entries found for matching criteria</xh:p>
                        )
                        else
                        (   
                            let $entry-transform := doc("/db/adamretter.org.uk/blog/entry.xslt") return
                                for $entry in $filtered-entries order by $entry/blog:article/@timestamp descending return
                                    transform:transform(<blog:entry-and-comments>{$entry}<blog:comments>{local:get-comments-for-entries($entry)}</blog:comments></blog:entry-and-comments>, $entry-transform, <parameters><param name="uri" value="{local:db-uri-to-web-uri(document-uri(root($entry)))}"/><param name="is-authenticated" value="{local:is-authenticated()}"/><param name="show-comments" value="{$show-comments}"/><param name="recaptcha-public-key" value="{$config:recaptcha-public-key}"/><param name="query-string" value="{request:get-query-string()}"/></parameters>)
                        )
                }
                </ars:additionals>
                <ars:extra-nav>
                    <ars:highlight>
                    {
                        for $year-month in distinct-values($blog-entries/blog:article/datetime:format-dateTime(@timestamp, 'yyyyMM')) order by $year-month descending return
                            <xh:div class="blogMonthYearEntries">
                                <xh:strong>{datetime:format-date(xs:date(concat(substring($year-month, 1, 4), "-", substring($year-month, 5), "-01")), "MMMM yyyy")}</xh:strong>
                                <xh:ul>
                                {
                                    for $article in $blog-entries/blog:article[datetime:format-dateTime(@timestamp, 'yyyyMM') eq $year-month] order by $article/@timestamp descending return
                                        <xh:li><xh:a href="{local:db-uri-to-web-uri(document-uri(root($article)))}" title="{$article/blog:title}">{$article/blog:title}</xh:a></xh:li>
                                }
                                </xh:ul>
                            </xh:div>
                                
                    }
                    </ars:highlight>
                    <ars:links>
                        <ars:title>Tag Cloud</ars:title>
                        {
                            let $tags := $blog-entries/blog:tags/blog:tag return
                                for $tag in distinct-values($tags) return
                                    (
                                        <xh:span style="{local:get-tag-css($tag, $tags)}"><xh:a href="blog.xql?tag={$tag}" title="{$tag}" class="tag">{$tag}</xh:a></xh:span>,
                                        text{ "&#32;" } (: required to split up the words in the tag cloud :)
                                    )
                        }
                    </ars:links>
                </ars:extra-nav>
            </ars:content>
        </ars:page>
};

declare function local:db-uri-to-web-uri($db-uri as xs:anyURI) as xs:anyURI
{
    xs:anyURI(replace(string($db-uri), "/db/adamretter.org.uk/", ""))
};

declare function local:get-tag-css($tag as xs:string, $tags as element(blog:tag)+) as xs:string
{
    let $base-font-size := 6,
    $tag-count := fn:count($tags[. = $tag]),
    $boost := if($tag-count gt 10)then(10)else($tag-count) return
        
        fn:concat("font-size: ", $base-font-size + ($boost * 2), "pt;")
};

declare function local:get-blog-entries($status as xs:string+) as element(blog:entry)*
{
    collection("/db/adamretter.org.uk/blog/entries")/blog:entry[@status = $status]
};

declare function local:no-filter($blog-entries as element(blog:entry)+) as element()+
{
    $blog-entries
};

declare function local:tag-filter($blog-entries as element(blog:entry)*) as element()*
{
    $blog-entries[blog:tags/blog:tag = request:get-parameter("tag", ())]
};

declare function local:entry-filter($blog-entries as element(blog:entry)*) as element()*
{
    $blog-entries[document-uri(root(.)) eq request:get-parameter("entry",())]
};

(:
for $param-name in request:get-parameter-names() return
    for $param-value in request:get-parameter($param-name, ()) return
        util:log("debug", concat("param=", $param-name, " value=", $param-value))
,
:)

let $is-authenticated := not(empty(session:get-attribute('_eXist_xmldb_user'))) return

    if(request:get-parameter-names() = ("atom"))then
    (
        util:declare-option("exist:serialize", "method=xml media-type=text/xml omit-xml-declaration=no"), (: should maybe be application/atom+xml :)
    
        if(request:get-parameter("entry",()))then
        (
            local:get-atom-entry(doc(request:get-parameter("entry",()))/blog:entry)
        )
        else
        (
            local:get-atom-feed()
        )
    )
    else
    (
        let $page :=  if(request:get-parameter("entry",()))then
            (
                if(request:get-parameter-names() = ("edit"))then
                (
                    local:edit-page(xs:anyURI(request:get-parameter("entry",())), "../../")
                )
                else if(request:get-parameter-names() = ("save"))then
                (
                    local:save-page(xs:anyURI(request:get-parameter("entry",())), "../../")
                )
                else if($is-authenticated and request:get-parameter-names() = ("remove-comment-as-spam"))then
                (
                    local:remove-comment-as-spam(request:get-parameter("comment-id",()))   
                )
                else
                (
                    local:page(util:function(xs:QName("local:entry-filter"), 1), "../../")
                )
            )
            else if(request:get-parameter("tag", ())) then
            (
                local:page(util:function(xs:QName("local:tag-filter"), 1), ())
            )
            else if(request:get-parameter("comment",()))then
            (
                if(asirra:validate-ticket(request:get-parameter("Asirra_Ticket",())))then
                (
                    let $entry-uri := xs:anyURI(request:get-parameter("comment", ())),
                    $new-comment-id := util:uuid(),
                    $is-comment-spam := local:is-comment-spam($new-comment-id) return
                    
                        let $comment := local:create-comment($entry-uri, $is-comment-spam, $new-comment-id) return
                            let $null := local:save-comment($entry-uri, $comment) return
                                let $comment-uri := fn:concat("http://www.adamretter.org.uk/", request:get-parameter("comment",()), "#comment_", $comment/@id),
                                $null := if($is-comment-spam)then
                                    local:send-new-spam-comment-notification-mail($comment-uri)
                                else
                                    local:send-new-comment-notification-mail($comment-uri)
                                return
                                    response:redirect-to(xs:anyURI(concat("http://www.adamretter.org.uk/", request:get-parameter("comment",()), if($is-comment-spam)then("?spam=true")else(), "#lastcomment")))
                )
                else
                (
                    response:redirect-to(xs:anyURI(concat(
                        "http://www.adamretter.org.uk/",
                        request:get-parameter("comment",()),
                        "?name=", encode-for-uri(request:get-parameter("name",())),
                        "&amp;website=", encode-for-uri(request:get-parameter("website",())),
                        "&amp;email=", encode-for-uri(request:get-parameter("email",())),
                        "&amp;comments=", encode-for-uri(request:get-parameter("comments",())),
                        "#addcomment"
                    )))
                )
            )
            else if(request:get-parameter-names() = ("login"))then
            (
                if(request:get-method() eq "GET")then
                (
                    local:blog-login()
                )
                else if(request:get-method() eq "POST")then
                (
                    local:blog-do-login(request:get-parameter("uid", ()), request:get-parameter("pwd",()))
                )else()
            )
            else if(request:get-parameter-names() = ("logout"))then
            (
                local:blog-do-logout()
            )
            else
            (
                local:page(util:function(xs:QName("local:no-filter"), 1), ())
            ) return
                
                if(request:get-parameter("test",()) eq "1")then
                (
                     transform:stream-transform($page, doc("/db/adamretter.org.uk/site.xslt"), ())
                )
                else
                (
                    (:
                    transform:transform($page, doc("/db/adamretter.org.uk/site.xslt"), ())
                    :)
                    transform:stream-transform($page, doc("/db/adamretter.org.uk/site.xslt"), ())
                )
    )